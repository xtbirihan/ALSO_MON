*&---------------------------------------------------------------------*
*& Include          ZFG_VCE_MONITOR_SEL
*&---------------------------------------------------------------------*
**********************************************************************
*& Key           : <AAHMEDOV>-140723
*& Request No.   : GAP 12 - PGAP-012_FS_Outbound_VCE_carrier_software_integration
**********************************************************************

TABLES: zstr_mon_ship_calc,
        ztout_add_serv.

SELECTION-SCREEN: BEGIN OF SCREEN 110.
  SELECT-OPTIONS: so_docno FOR zstr_mon_ship_calc-docno.
SELECTION-SCREEN END OF SCREEN 110.

SELECTION-SCREEN: BEGIN OF SCREEN 120.
  PARAMETERS: p_scond      TYPE /scdl/dl_service_level_code,
              p_fcarr TYPE zde_cshipcond.
  SELECT-OPTIONS: so_adsrv FOR ztout_add_serv-add_serv.
SELECTION-SCREEN: END OF SCREEN 120.
