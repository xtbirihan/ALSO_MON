**********************************************************************
*& Key           : LH-021223
*& Request No.   : GAP-37-40 – "Additional Product Master Fields”
**********************************************************************
*& Description (short)
*& Copied from FG /SCWM/PROD_OVERVIEW and added the new customer
*& fields handling. Only relevant parts are copied.
**********************************************************************
*******************************************************************
*   System-defined Include-files.                                 *
*******************************************************************
  INCLUDE lzfg_prod_overviewtop.           " Global Declarations
  INCLUDE lzfg_prod_overviewuxx.           " Function Modules

*******************************************************************
*   User-defined Include-files (if necessary).                    *
*******************************************************************
* INCLUDE /SCWM/LPROD_OVERVIEWF...           " Subroutines
* INCLUDE /SCWM/LPROD_OVERVIEWO...           " PBO-Modules
* INCLUDE /SCWM/LPROD_OVERVIEWI...           " PAI-Modules
* INCLUDE /SCWM/LPROD_OVERVIEWE...           " Events
* INCLUDE /SCWM/LPROD_OVERVIEWP...           " Local class implement.
* INCLUDE /SCWM/LPROD_OVERVIEWT99.           " ABAP Unit tests

*INCLUDE /scwm/lprod_overviewp01.

  INCLUDE lzfg_prod_overviewf01.
*INCLUDE /scwm/lprod_overviewf01.

*INCLUDE /scwm/lprod_overviewf02.

*INCLUDE LZFG_PROD_OVERVIEWF04.
  INCLUDE /scwm/lprod_overviewf04.

*INCLUDE LZFG_PROD_OVERVIEWF03.
  INCLUDE /scwm/lprod_overviewf03.

*INCLUDE LZFG_PROD_OVERVIEWF05.
  INCLUDE /scwm/lprod_overviewf05.
