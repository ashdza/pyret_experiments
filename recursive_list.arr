data Listt:
  | L(first :: Any, rest :: Listt) with:
    length(self): 1 + self.rest.length() end,
    map(self, t :: Function): L(t(self.first), self.rest.map(t)) end,
    filter(self, p :: Function): 
      if p(self.first):
        L(self.first, self.rest.filter(p))
      else: self.rest.filter(p) 
      end
    end
  | null with:
    length(self): 0 end,
    map(self, t :: Function): null end,
    filter(self, p :: Function): null end
where:
  l1 = L(1, L(2, null))
  l1.length() is 2
  l1.map(_ + 3) is L(4, L(5, null))
  l1.filter(_ > 1) is L(2, null)
end

fun length(l:: Listt) -> Number:
  doc: "Returns number of terms in l"
  cases(Listt) l:
    | null => 0
    | L(f, r) => 1 + length(r)
  end
where:
  length(null) is 0
  length(L(1, L(2, null))) is 2
end

fun mapp(l:: Listt, t:: Function) -> Listt:
  doc: "Returns a new list, each element e = t(x) for x in l"
  cases(Listt) l:
    | null => null
    | L(f, r) => L(t(f), mapp(r, t))
  end
where:
  fun add5(n): n + 5 end
  mapp(L(1, L(2, null)), add5) is L(6, L(7, null))
  mapp(L("bob", L("bobbity", null)), string-length) is L(3, L(7, null))
end

fun filterr(l:: Listt, p:: Function) -> Listt:
  doc: "Returns a new list consisting of each term in l satisfying condition p"
  foldd(l, lam(a,b): if p(a): L(a,b) else: b end end, null)
  cases(Listt) l:
    | null => null
    | L(f, r) => if p(f): L(f, filterr(r, p)) else: filterr(r, p) end
  end
where:
  fun odd(n): num-modulo(n, 2) == 1 end
  filterr(L(1, L(2, L(3, null))), odd) is L(1, L(3, null))
  filterr(L("bob", L("bobbity", null)), 
    lam(s): string-length(s) > 5 end) is L("bobbity", null)
end

fun foldd(l:: Listt, c:: Function, v:: Any) -> Any:
  doc: "For list l1,l2,l3 returns a value c(l1, c(l2, c(l3, v)))"
  cases(Listt) l:
    | null => v
    | L(f, r) => c(f, foldd(r, c, v))
  end
where:
  l1 = L(2, L(3, L(4, null)))
  l2 = L("bob", L("bobbity", null))
  foldd(l1, lam(x,y): x + y end, 0) is 9
  foldd(l1, lam(x,y): x * y end, 1) is 24
  foldd(l2, string-append, "") is "bobbobbity"
end

fun append(l1:: Listt, l2:: Listt) -> Listt:
  cases (Listt) l1:
    | null => l2
    | L(f, r) => L(f, append(r, l2))
  end
where:
  l1 = L(1, L(2, null))
  l2 = L(3, L(4, null))
  append(l1, l2) is L(1, L(2, L(3, L(4, null))))
end