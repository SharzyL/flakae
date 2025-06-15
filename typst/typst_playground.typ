For any $k, x$, denote by $v_(k, x)$ the probability that A wins B by $x$ scores on round $k$.

Now $
p_(2m + 1) &= sum_(x >= 2) v_(2m + 1, x) = sum_(x >= 3) v_(2m + 1, x) \
&= sum_(x >= 3) (p dot.c v_(2m, x - 1) + q dot.c v_(2m, x + 1)) \
&= p sum_(x >= 2) v_(2m, x) + q sum_(x >= 4) v_(2m, x) \
&= p dot.c p_(2m) + q dot.c (p_(2m) - v_(2m, 2)) \
&= p_(2m) - q v_(2m, 2) \
&= p_(2m) - binom(2m, m + 1) p^(m + 1) q^(m).
$

Similarly $
q_(2m + 1) = q_(2m) - binom(2m, m + 1) p^(m) q^(m + 1).
$
