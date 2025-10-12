# This file was generated, do not modify it. # hide
DataFrame(
    a = [3, 4, 1, 2, 3, 4, 5, 6, 7, 8],
    b = 2:11,
    c = 3:12
  ) |> filter(:b < :a)