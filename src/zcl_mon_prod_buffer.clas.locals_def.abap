*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section
CLASS lcx_no_material DEFINITION INHERITING FROM cx_static_check.

ENDCLASS.

CLASS lcx_not_qualified DEFINITION INHERITING FROM cx_static_check.

ENDCLASS.

CLASS lcx_interface_incorrect DEFINITION INHERITING FROM cx_static_check.

ENDCLASS.

CLASS lcx_data_not_found DEFINITION INHERITING FROM cx_static_check.

ENDCLASS.

CLASS lcx_text_not_found DEFINITION FINAL INHERITING FROM cx_static_check.

ENDCLASS.

TYPES:
  tt_lock_mass_pr TYPE STANDARD TABLE OF /sapapo/matkey_lock.

TYPES:
  tt_matid TYPE STANDARD TABLE OF /sapapo/matid_str .
TYPES:
  BEGIN OF ty_matnr_range ,          "product number
    sign   TYPE  /scmb/sign,
    option TYPE  /scmb/option,
    low    TYPE  /sapapo/matnr,
    high   TYPE  /sapapo/matnr,
  END OF ty_matnr_range .
TYPES:
  BEGIN OF ty_matid_range ,          "product number
    sign   TYPE  /scmb/sign,
    option TYPE  /scmb/option,
    low    TYPE  /sapapo/matid,
    high   TYPE  /sapapo/matid,
  END OF ty_matid_range .
TYPES:
  tt_matnr_range  TYPE STANDARD TABLE OF ty_matnr_range .
TYPES:
  tt_matid_range  TYPE STANDARD TABLE OF ty_matid_range .
TYPES:
  BEGIN OF ty_entid_range ,
    sign   TYPE  /scmb/sign,
    option TYPE  /scmb/option,
    low    TYPE  bu_partner_guid,
    high   TYPE  bu_partner_guid,
  END OF ty_entid_range .
TYPES:
  tt_entid_range  TYPE STANDARD TABLE OF ty_entid_range .
TYPES:
  tt_ext_matkey  TYPE STANDARD TABLE OF /sapapo/ext_matkey .
TYPES:
  tt_ext_matkeyx  TYPE STANDARD TABLE OF /sapapo/ext_matkeyx .
TYPES:
  tt_ext_matlwh  TYPE STANDARD TABLE OF /sapapo/ext_matlwh .
TYPES:
  tt_ext_matlwhx  TYPE STANDARD TABLE OF /sapapo/ext_matlwhx .
TYPES:
  tt_ext_matlwhst  TYPE STANDARD TABLE OF /sapapo/ext_matlwhst .
TYPES:
  tt_ext_matlwhstx  TYPE STANDARD TABLE OF /sapapo/ext_matlwhstx .
TYPES:
  BEGIN OF ty_prod,
    matid   TYPE /sapapo/matid, "scm id
    matnr   TYPE /sapapo/matnr, "/SCWM/DE_MATNR,
    matguid TYPE /scwm/de_matid, "Product GUID
  END OF ty_prod .
TYPES:
  tt_prod TYPE STANDARD TABLE OF ty_prod .
TYPES:
  BEGIN OF ty_lgnum_matlwh.
    INCLUDE TYPE /scwm/s_material_lgnum.
    TYPES:
       createuser          TYPE ernam,
       createutc           TYPE /sapapo/tsucr,
       changeuser          TYPE aenam,
       changeutc           TYPE /sapapo/tsuup,
  END OF ty_lgnum_matlwh.
TYPES:
  tt_lgnum_matlwh TYPE STANDARD TABLE OF ty_lgnum_matlwh.

INTERFACE lif_isolated_doc.

  METHODS: set_lgnum
    IMPORTING
      iv_lgnum    TYPE /scwm/lgnum
    EXPORTING
      ev_lgnum    TYPE /scwm/lgnum
      ev_scuguid  TYPE /scmb/mdl_scuguid
      ev_scu      TYPE /scmb/oe_entity
      et_entitled TYPE bup_partner_guid_t.

  METHODS: get_entitled
    IMPORTING
      iv_lgnum    TYPE /scwm/lgnum
    EXPORTING
      et_entitled TYPE bup_partner_guid_t.

  METHODS: get_scuguid
    IMPORTING
              iv_lgnum          TYPE /scwm/lgnum
    RETURNING VALUE(rv_scuguid) TYPE /scmb/mdl_scuguid.

  METHODS: dm_matid_get
    IMPORTING
      it_matnr_rtab    TYPE  /sapapo/mat_nr_rtab
      iv_snp_use_check TYPE  xfeld OPTIONAL
    EXPORTING
      et_matid         TYPE  /sapapo/matid_tab
    RAISING
      lcx_not_qualified
      lcx_no_material.

  METHODS: sapapo_product_dm_read
    IMPORTING
      iv_langu      TYPE langu
      is_exclude    TYPE /sapapo/mat_selflags_str
      it_matid      TYPE tt_matid
      it_matnr      TYPE /sapapo/matnr_tab
    EXPORTING
      et_matkey_out TYPE /sapapo/matkey_out_tab
      et_marm       TYPE /sapapo/marm_tab
      et_mattxt     TYPE /sapapo/mattxt_tab
      et_matpack    TYPE /sapapo/matpack_tab
      et_matexec    TYPE /sapapo/matexec_tab.

  METHODS: read_matlwh_multi
    IMPORTING
      iv_lgnum          TYPE /scwm/lgnum
      iv_scuguid        TYPE /scmb/mdl_scuguid
      it_entitled       TYPE bup_partner_guid_t
      it_mat_nr_id_guid TYPE tt_prod
      it_material       TYPE /sapapo/matkey_out_tab
    EXPORTING
      et_prod_lwh       TYPE tt_lgnum_matlwh.

  METHODS: sapapo_matlwhst_read_multi_2
    IMPORTING
      it_key      TYPE /sapapo/dm_matlwhst_id_tab
    EXPORTING
      et_prodwhst TYPE /sapapo/dm_matlwhst_tab.

  METHODS: get_prod_id
    IMPORTING
      !iv_selection_mode TYPE c
      !iv_scuguid        TYPE /scmb/mdl_scuguid
      !it_entitled       TYPE bup_partner_guid_t
      !it_matnr_range    TYPE tt_matnr_range
    EXPORTING
      !et_matid_tab      TYPE tt_matid.

  METHODS: enqueue_optimistic
    IMPORTING
      !iv_matnr        TYPE /sapapo/ext_matnr
      !io_lock_mass_pr TYPE REF TO /scmb/if_md_lock_mass_maint
    EXPORTING
      !ev_failed       TYPE abap_bool
    CHANGING
      !ct_return       TYPE bapiret2_t.

  METHODS: product_authority_check
    IMPORTING
      !iv_matnr  TYPE /sapapo/ext_matnr
      !iv_actvt  TYPE activ_auth
      !iv_lgnum  TYPE /scwm/lgnum OPTIONAL
    EXPORTING
      !ev_failed TYPE abap_bool
    CHANGING
      !ct_return TYPE bapiret2_t.

  METHODS: sapapo_dm_products_maintain
    IMPORTING
      !it_ext_matkey       TYPE tt_ext_matkey
      !it_ext_matkeyx      TYPE tt_ext_matkeyx
      !it_ext_matlwh       TYPE tt_ext_matlwh
      !it_ext_matlwhx      TYPE tt_ext_matlwhx
      !it_ext_matlwhst     TYPE tt_ext_matlwhst
      !it_ext_matlwhstx    TYPE tt_ext_matlwhstx
      !it_list_locked_prod TYPE tt_lock_mass_pr
    EXPORTING
      !et_return           TYPE bapiret2_t
      !ev_abort            TYPE abap_bool.

  METHODS: buffer_mapping_mat_nr_id_guid
    IMPORTING
      it_material       TYPE /sapapo/matkey_out_tab
    EXPORTING
      et_mat_nr_id_guid TYPE tt_prod.

ENDINTERFACE.
