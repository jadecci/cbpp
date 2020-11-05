# HCP surface CBPP benchmark information

The table below shows estimates of run-tim and memory usage of running CBPP on HCP surface data, at different granularity with different regression algorithms.

Each `whole-brain` run uses 10 repeats and 1 psychometric score. For `SVR` and `MLR`, each `parcel-wise` run uses 100 repeats and 100 psychometric scores, while for `EN` and `RR`, each run uses 100 repeats too but only 1 psychometric score.

Note that the run-time values are averaged across multiple runs on cpus with different performance, and hence serve as rough estimates at best.

1. **SVR (Support Vector Regression)**

| Granularity | Whole-brain CBPP <br> Run-time (min) | Whole-brain CBPP <br> Memory (GB) | Parcel-wise CBPP <br> Run-time (min) | Parcel-wise CBPP <br> Mem (GB)
| :--: | :--: | :--: | :--: | :--: | :--:
| 100-parcel | 0.7 | 0.6 | 90 | 0.4
| 200-parcel | 3 | 1.2 | 30 | 0.6
| 300-parcel | 7 | 2.2 | 40 | 1
| 400-parcel | 13 | 3.6 | 50 | 1.5

This compares to a similar implementation in Python:

| Granularity | Whole-brain CBPP <br> Run-time (min) | Whole-brain CBPP <br> Memory (GB) | Parcel-wise CBPP <br> Run-time (min) | Parcel-wise CBPP <br> Mem (GB)
| :--: | :--: | :--: | :--: | :--: | :--:
| 100-parcel | 14 | 0.3 | 30 | 0.05
| 200-parcel | 78 | 0.9 | 70 | 0.6
| 300-parcel | 125 | 1.9 | 120 | 1.3
| 400-parcel | 155 | 3.2 | 170 | 2.2

2. **MLR (multiple liner regression)**

| Granularity | Whole-brain CBPP <br> Run-time (min) | Whole-brain CBPP <br> Memory (GB) | Parcel-wise CBPP <br> Run-time (min) | Parcel-wise CBPP <br> Mem (GB)
| :--: | :--: | :--: | :--: | :--: | :--:
| 100-parcel | 0.2 | 0.6 | 13 | 0.4
| 200-parcel | 0.5 | 1 | 40 | 0.6
| 300-parcel | 1.2 | 1.9 | 75 | 1
| 400-parcel | 2 | 3 | 125 | 1.5

3. **EN (Elastic nets)**

| Granularity | Whole-brain CBPP <br> Run-time (min) | Whole-brain CBPP <br> Memory (GB) | Parcel-wise CBPP <br> Run-time (min) | Parcel-wise CBPP <br> Mem (GB)
| :--: | :--: | :--: | :--: | :--: | :--:
| 100-parcel | 180 | 0.7 | 20 | 0.4
| 200-parcel | 200 | 1.1 | 110 | 0.6
| 300-parcel | 250 | 2.1 | 240 | 1
| 400-parcel | 340 | 3.4 | 500 | 1.5

4. **RR (ridge regression)**

| Granularity | Whole-brain CBPP <br> Run-time (min) | Whole-brain CBPP <br> Memory (GB) | Parcel-wise CBPP <br> Run-time (min) | Parcel-wise CBPP <br> Mem (GB)
| :--: | :--: | :--: | :--: | :--: | :--:
| 100-parcel | 30 | 0.8 | 3 | 0.4
| 200-parcel | 120 | 1.5 | 30 | 0.6
| 300-parcel | 300 | 2.9 | 31 | 1
| 400-parcel | 600 | 4.7 | 33 | 1.5
