import pstats

stats = pstats.Stats("profile.out")
stats.sort_stats("tottime")

stats.print_stats(20)
