FUNCTION z_wo_prio_change_mon.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LGNUM) TYPE  /SCWM/LGNUM
*"     REFERENCE(IT_DATA) TYPE  STANDARD TABLE
*"----------------------------------------------------------------------
**********************************************************************
*& Key           : <RMANOVA>-25.10.2023
*& Request No.   : GAP-076 FD Priority settings
**********************************************************************
**********************************************************************
*& Description (short)
*& Update all WHOs in table /SCWM/WO_RSRC_TY
**********************************************************************

  DATA:
    lo_helper TYPE REF TO lcl_who_helper.

  lo_helper = NEW lcl_who_helper( ).
  lo_helper->update_who_prio( iv_lgnum = iv_lgnum
                              it_data  = it_data ).

ENDFUNCTION.
