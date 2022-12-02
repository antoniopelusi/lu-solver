# Assignment 1: LU solver with OpenMP
## Participants:
- Antonio Pelusi 257241 257241@studenti.unimore.it
- Gaia Forghieri gaia.forghieri gaia.forghieri@gmail.com
- Alberto Stefani 257434 257434@studenti.unimore.it
- Fjona Minga 316840 316840@studenti.unimore.it

## Files:
1. **lu.c**: without parallelization
2. **lu_for_static.c**: with *parallel for static (1, 256, and 1024 chunk size)*
3. **lu_for_dynamic.c**: with *parallel for dynamic (1, 256, and 1024 chunk size)*
4. **lu_for_guided.c**: with *parallel for guided (1, 256, and 1024 chunk size)*
5. **lu_gpu.c**: with *GPU offloading*
6. **lu_wrong_for**: with *parallel for static* but with race condition problem (wrong results)
7. **lu_wrong_sections**: with *parallel sections* but with race condition problem (wrong results)
