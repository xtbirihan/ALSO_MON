*"* use this source file for your ABAP unit test classes

*"--------------------------------------------------------------------------------------------------------------
*" LTD - Test double for main class
*"--------------------------------------------------------------------------------------------------------------
CLASS ltd_mon_prod DEFINITION FINAL FOR TESTING
                INHERITING FROM ZCL_MON_PROD_BUFFER.
  PUBLIC SECTION.
    INTERFACES lif_isolated_doc             PARTIALLY IMPLEMENTED.

    DATA:
      mv_test_object1           TYPE abap_bool.

  PRIVATE SECTION.
    DATA:
      mv_dummy       TYPE abap_bool..
ENDCLASS.







CLASS ltd_mon_prod IMPLEMENTATION.

  METHOD lif_isolated_doc~set_lgnum.
    ev_lgnum = 'EW01'.
    ev_scuguid = '42F2E9AFC5FF1ED6A2AA6BD3CC27D0E3'.
    et_entitled =  VALUE #( ( partner = 'BPEW01' partner_guid = '42F2E9AFBE7F1EE6A2A99B7342B94880' ) ).
  ENDMETHOD.

  METHOD lif_isolated_doc~get_entitled.
  ENDMETHOD.

  METHOD lif_isolated_doc~get_scuguid.
  ENDMETHOD.

  METHOD lif_isolated_doc~dm_matid_get.
  ENDMETHOD.

  METHOD lif_isolated_doc~buffer_mapping_mat_nr_id_guid.
    et_mat_nr_id_guid = VALUE #( ( matnr = 'PROD_UNIT_TEST_01' matid = 'GFBfhyNu7jU5mk9LsTpMwm' matguid = '1' )
                                  ( matnr = 'PROD_UNIT_TEST_02' matid = 'GFBfhyNu7jU5mk9LsTpMwn' matguid = '2' )
                                  ( matnr = 'PROD_UNIT_TEST_03' matid = 'GFBfhyNu7jU5mk9LsTpMwo' matguid = '3' ) ).
  ENDMETHOD.

  METHOD lif_isolated_doc~sapapo_product_dm_read.

*   et_matpack = VALUE #( ( mandt = '003' matid = 'GFBfhyNu7jU5mk9LsTpMwm' maxw = 1000 maxw_uom = 'KG' pmtyp = 'PT01') ).
*   et_matexec = VALUE #( ( mandt = '003' matid = 'GFBfhyNu7jU5mk9LsTpMwm' whmatgr = 'GR01' ) ).
*   et_mattxt = VALUE #( ( mandt = '003' matid = 'GFBfhyNu7jU5mk9LsTpMwm' maktx = 'MUFFIN' ) ).

    DATA: lt_sapapo_mattxt    TYPE  /sapapo/mattxt_tab,
          lt_sapapo_matpack   TYPE  /sapapo/matpack_tab,
          lt_sapapo_matexec   TYPE  /sapapo/matexec_tab,
          lt_material         TYPE /sapapo/matkey_out_tab,
          lt_prodlwh          TYPE /sapapo/dm_matlwh_tab,
          lt_prod_mon_outtemp TYPE /scwm/tt_prod_mon_out,
          ls_prod_mon_outtemp TYPE /scwm/s_prod_mon_out,
          lv_lines            TYPE i,
          lt_matnr_range      TYPE tt_matnr_range,
          ls_matnr_range      TYPE ty_matnr_range,
          lt_matlwh           TYPE /scwm/tt_prod_mon_out.



    et_matkey_out = VALUE #( ( matid = 'GFBfhyNu7jU5mk9LsTpMwm' matnr = 'PROD_UNIT_TEST_01' )
                             ( matid = 'GFBfhyNu7jU5mk9LsTpMwn' matnr = 'PROD_UNIT_TEST_02' )
                             ( matid = 'GFBfhyNu7jU5mk9LsTpMwo' matnr = 'PROD_UNIT_TEST_03' ) ).

    lt_sapapo_matpack = VALUE #( ( mandt = '003' matid = 'GFBfhyNu7jU5mk9LsTpMwm' maxw = 1000 maxw_uom = 'KG' pmtyp = 'PT01') ).
    lt_sapapo_matexec = VALUE #( ( mandt = '003' matid = 'GFBfhyNu7jU5mk9LsTpMwm' whmatgr = 'GR01' ) ).
    lt_sapapo_mattxt = VALUE #( ( mandt = '003' matid = 'GFBfhyNu7jU5mk9LsTpMwm' maktx = 'MUFFIN' ) ).


  ENDMETHOD.

  METHOD lif_isolated_doc~read_matlwh_multi.

    et_prod_lwh =  VALUE #( ( matid = '1' lgnum = 'EW013' entitled = 'BPEW01' put_stra = 'PA10' )
                          ( matid = '2' lgnum = 'EW013'  entitled = 'BPEW01' put_stra = 'PA20' ) ).
  ENDMETHOD.


  METHOD lif_isolated_doc~sapapo_matlwhst_read_multi_2.

    et_prodwhst = VALUE #( ( matid = 'GFBfhyNu7jU5mk9LsTpMwn' scuguid = '42F2E9AFC5FF1ED6A2AA6BD3CC27D0E3' entitled_id = '42F2E9AFBE7F1EE6A2A99B7342B94880' lgtyp = 'T010' bintype = 'ABCD' ) ).

  ENDMETHOD.


  METHOD lif_isolated_doc~get_prod_id.
    et_matid_tab = VALUE #( ( matid = 'cccccccccccc' ) ). " dummy value
  ENDMETHOD.



  METHOD lif_isolated_doc~enqueue_optimistic.
    IF iv_matnr = 'PROD_UNIT_TEST_03'.
      ev_failed = 'X'.
    ELSE.
      CLEAR ev_failed.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD lif_isolated_doc~product_authority_check.
    IF iv_matnr = 'PROD_UNIT_TEST_04'.
      ev_failed = 'X'.
    ELSE.
      CLEAR ev_failed.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD lif_isolated_doc~sapapo_dm_products_maintain.
    RETURN.
  ENDMETHOD.

ENDCLASS.








*"--------------------------------------------------------------------------------------------------------------
*" LTH - Test helper class with common part for all tests
*"--------------------------------------------------------------------------------------------------------------
CLASS lth_common_parts DEFINITION DEFERRED.
CLASS ZCL_MON_PROD_BUFFER DEFINITION LOCAL FRIENDS lth_common_parts.


CLASS lth_common_parts DEFINITION FOR TESTING
                       DURATION SHORT
                       RISK LEVEL HARMLESS.

  PROTECTED SECTION.
    DATA:
      mo_cut TYPE REF TO ZCL_MON_PROD_BUFFER,
      mo_td  TYPE REF TO ltd_mon_prod.
  PRIVATE SECTION.
    METHODS:
      setup.
ENDCLASS.

CLASS lth_common_parts IMPLEMENTATION.
  METHOD setup.
    mo_td           = NEW ltd_mon_prod( ).
    mo_cut          = NEW ZCL_MON_PROD_BUFFER( ).
    DATA(lo_cut)    = CAST ZCL_MON_PROD_BUFFER( mo_cut ).
    lo_cut->mo_isolated_doc        = mo_td.
  ENDMETHOD.
ENDCLASS.







*"--------------------------------------------------------------------------------------------------------------
*" LTC - Test Classes
*"--------------------------------------------------------------------------------------------------------------


CLASS ltc_mon_prod DEFINITION FINAL FOR TESTING
                        DURATION SHORT
                        RISK LEVEL HARMLESS
                        INHERITING FROM lth_common_parts.
  "#AU Duration Short
  PRIVATE SECTION.
    METHODS integrate_sapapo_data FOR TESTING.
    METHODS create_list_of_wh_products FOR TESTING.
    METHODS get_prod_node_data FOR TESTING.
    METHODS wh_prod_mass_change FOR TESTING.
    METHODS get_styp_node_data FOR TESTING.
ENDCLASS.


CLASS ltc_mon_prod IMPLEMENTATION.






  METHOD integrate_sapapo_data.
    DATA: lt_sapapo_mattxt  TYPE  /sapapo/mattxt_tab,
          lt_sapapo_matpack TYPE  /sapapo/matpack_tab,
          lt_sapapo_matexec TYPE  /sapapo/matexec_tab,
          ls_product        TYPE /scwm/s_prod_mon_out.

    ls_product = VALUE #( matid = 'GFBfhyNu7jU5mk9LsTpMwm' matnr = 'PROD_UNIT_TEST_01' ).
    lt_sapapo_matpack = VALUE #( ( mandt = '003' matid = 'GFBfhyNu7jU5mk9LsTpMwm' maxw = 1000 maxw_uom = 'KG' pmtyp = 'PT01') ).
    lt_sapapo_matexec = VALUE #( ( mandt = '003' matid = 'GFBfhyNu7jU5mk9LsTpMwm' whmatgr = 'GR01' ) ).
    lt_sapapo_mattxt = VALUE #( ( mandt = '003' matid = 'GFBfhyNu7jU5mk9LsTpMwm' maktx = 'MUFFIN' ) ).

    CALL METHOD mo_cut->integrate_sapapo_data
      EXPORTING
        it_sapapo_mattxt  = lt_sapapo_mattxt
        it_sapapo_matpack = lt_sapapo_matpack
        it_sapapo_matexec = lt_sapapo_matexec
        iv_lgnum          = 'EW01'
        iv_matid          = 'GFBfhyNu7jU5mk9LsTpMwm'
      CHANGING
        cs_product        = ls_product.

    cl_aunit_assert=>assert_equals( act = ls_product-maxw exp = '1000'
                    msg = 'Field Maxw is not correct').
    cl_aunit_assert=>assert_equals( act = ls_product-maxw_uom exp = 'KG'
                    msg = 'Field Maxw_uom is not correct').
    cl_aunit_assert=>assert_equals( act = ls_product-pmtyp exp = 'PT01'
                    msg = 'Field pmtyp is not correct').
    cl_aunit_assert=>assert_equals( act = ls_product-whmatgr exp = 'GR01'
                    msg = 'Field WHMATGR is not correct').
    cl_aunit_assert=>assert_equals( act = ls_product-maktx exp = 'MUFFIN'
                    msg = 'Field Maxw is not correct').

*    lv_lines = lines( ls_shift_seq-shift_details ).

  ENDMETHOD.









  METHOD create_list_of_wh_products.
    DATA: lt_sapapo_mattxt    TYPE  /sapapo/mattxt_tab,
          lt_sapapo_matpack   TYPE  /sapapo/matpack_tab,
          lt_sapapo_matexec   TYPE  /sapapo/matexec_tab,
          lt_material         TYPE /sapapo/matkey_out_tab,
*          lt_prodlwh          TYPE /scwm/tt_material_lgnum,
          lt_prodlwh          TYPE tt_lgnum_matlwh,
          lt_prod_mon_outtemp TYPE /scwm/tt_prod_mon_out,
          ls_prod_mon_outtemp TYPE /scwm/s_prod_mon_out,
          lv_lines            TYPE i.



    lt_material = VALUE #( ( matid = 'GFBfhyNu7jU5mk9LsTpMwm' matnr = 'PROD_UNIT_TEST_01' )
                           ( matid = 'GFBfhyNu7jU5mk9LsTpMwn' matnr = 'PROD_UNIT_TEST_02' ) ).

    lt_sapapo_matpack = VALUE #( ( mandt = '003' matid = 'GFBfhyNu7jU5mk9LsTpMwm' maxw = 1000 maxw_uom = 'KG' pmtyp = 'PT01') ).
    lt_sapapo_matexec = VALUE #( ( mandt = '003' matid = 'GFBfhyNu7jU5mk9LsTpMwm' whmatgr = 'GR01' ) ).
    lt_sapapo_mattxt = VALUE #( ( mandt = '003' matid = 'GFBfhyNu7jU5mk9LsTpMwm' maktx = 'MUFFIN' ) ).

    lt_prodlwh =  VALUE #( ( matid = '1' lgnum = 'EW01'  entitled = 'BPEW01' put_stra = 'PA10' ) ).


    CALL METHOD mo_cut->set_lgnum
      EXPORTING
        iv_lgnum = 'EW01'.

    mo_cut->mt_mat_nr_id_guid = VALUE #( ( matid = 'GFBfhyNu7jU5mk9LsTpMwm' matnr = 'PROD_UNIT_TEST_01' matguid = '1' )
                                         ( matid = 'GFBfhyNu7jU5mk9LsTpMwn' matnr = 'PROD_UNIT_TEST_02' matguid = '2' ) ).
* with wh product only
    CLEAR lt_prod_mon_outtemp.
    CALL METHOD mo_cut->create_list_of_wh_products
      EXPORTING
        iv_lgnum          = 'EW01'
        it_material       = lt_material
        it_sapapo_mattxt  = lt_sapapo_mattxt
        it_sapapo_matpack = lt_sapapo_matpack
        it_sapapo_matexec = lt_sapapo_matexec
        it_wh_product     = lt_prodlwh
        iv_selection_mode = 'W'
      IMPORTING
        et_data           = lt_prod_mon_outtemp.

    lv_lines = lines( lt_prod_mon_outtemp ).
    cl_aunit_assert=>assert_equals( act = lv_lines exp = '1' ).

    READ TABLE lt_prod_mon_outtemp INTO ls_prod_mon_outtemp INDEX 1.
    cl_aunit_assert=>assert_equals( act = ls_prod_mon_outtemp-put_stra exp = 'PA10' ).


* without wh product only
    CLEAR lt_prod_mon_outtemp.
    CALL METHOD mo_cut->create_list_of_wh_products
      EXPORTING
        iv_lgnum          = 'EW01'
        it_material       = lt_material
        it_sapapo_mattxt  = lt_sapapo_mattxt
        it_sapapo_matpack = lt_sapapo_matpack
        it_sapapo_matexec = lt_sapapo_matexec
        it_wh_product     = lt_prodlwh
        iv_selection_mode = 'N'
      IMPORTING
        et_data           = lt_prod_mon_outtemp.

    lv_lines = lines( lt_prod_mon_outtemp ).
    cl_aunit_assert=>assert_equals( act = lv_lines exp = '1' ).

    READ TABLE lt_prod_mon_outtemp INTO ls_prod_mon_outtemp INDEX 1.
    cl_aunit_assert=>assert_initial( ls_prod_mon_outtemp-put_stra ).

* all products
    CLEAR lt_prod_mon_outtemp.
    CALL METHOD mo_cut->create_list_of_wh_products
      EXPORTING
        iv_lgnum          = 'EW01'
        it_material       = lt_material
        it_sapapo_mattxt  = lt_sapapo_mattxt
        it_sapapo_matpack = lt_sapapo_matpack
        it_sapapo_matexec = lt_sapapo_matexec
        it_wh_product     = lt_prodlwh
        iv_selection_mode = 'E'
      IMPORTING
        et_data           = lt_prod_mon_outtemp.

    lv_lines = lines( lt_prod_mon_outtemp ).
    cl_aunit_assert=>assert_equals( act = lv_lines exp = '2' ).

  ENDMETHOD.










  METHOD get_prod_node_data.
    DATA: lt_sapapo_mattxt    TYPE  /sapapo/mattxt_tab,
          lt_sapapo_matpack   TYPE  /sapapo/matpack_tab,
          lt_sapapo_matexec   TYPE  /sapapo/matexec_tab,
          lt_material         TYPE /sapapo/matkey_out_tab,
          lt_prodlwh          TYPE /sapapo/dm_matlwh_tab,
          lt_prod_mon_outtemp TYPE /scwm/tt_prod_mon_out,
          ls_prod_mon_outtemp TYPE /scwm/s_prod_mon_out,
          lv_lines            TYPE i,
          lt_matnr_range      TYPE tt_matnr_range,
          ls_matnr_range      TYPE ty_matnr_range,
          lt_matlwh           TYPE /scwm/tt_prod_mon_out.

* option show only products with warehouse product
    CALL METHOD mo_cut->get_prod_node_data
      EXPORTING
        iv_lgnum        = 'EW01'
        iv_show_wh_only = abap_true
      IMPORTING
        et_data         = lt_matlwh.

    lv_lines = lines( lt_matlwh ).
    cl_aunit_assert=>assert_equals( act = lv_lines exp = '2' ).

* option show only products with no warehouse product
    CALL METHOD mo_cut->get_prod_node_data
      EXPORTING
        iv_lgnum            = 'EW01'
        iv_show_non_wh_only = abap_true
      IMPORTING
        et_data             = lt_matlwh.

    lv_lines = lines( lt_matlwh ).
    cl_aunit_assert=>assert_equals( act = lv_lines exp = '1' ).

* option show all products
    CALL METHOD mo_cut->get_prod_node_data
      EXPORTING
        iv_lgnum           = 'EW01'
        iv_show_every_prod = abap_true
      IMPORTING
        et_data            = lt_matlwh.

    lv_lines = lines( lt_matlwh ).
    cl_aunit_assert=>assert_equals( act = lv_lines exp = '3' ).
  ENDMETHOD.












  METHOD wh_prod_mass_change.
    DATA:
      lt_matkey          TYPE tt_ext_matkey,
      lt_matkeyx         TYPE tt_ext_matkeyx,
      lt_matlwh_create   TYPE tt_ext_matlwh,
      lt_matlwh_update   TYPE tt_ext_matlwh,
      lt_matlwhx         TYPE tt_ext_matlwhx,
      lt_matlwhst_create TYPE tt_ext_matlwhst,
      lt_matlwhst_update TYPE tt_ext_matlwhst,
      lt_matlwhstx       TYPE tt_ext_matlwhstx,
      lt_return          TYPE bapiret2_t,
      lv_abort           TYPE abap_bool,
      lv_lines           TYPE int8,
      lv_lines_st        TYPE int8.



    lt_matkey = VALUE #( ( method = 'C' ext_matnr = 'PROD_UNIT_TEST_01' )
                           ( method = 'C' ext_matnr = 'PROD_UNIT_TEST_02' ) ).
    lt_matkeyx = VALUE #( ( ext_matnr = 'PROD_UNIT_TEST_01' )
                           ( ext_matnr = 'PROD_UNIT_TEST_02' ) ).

    lt_matlwh_create =  VALUE #( ( ext_matnr = 'PROD_UNIT_TEST_01' ext_entity = 'SCU_LM01' ext_entitled = 'PL_LM01' put_stra = 'PA10' ) ).
    lt_matlwh_update =  VALUE #( ( ext_matnr = 'PROD_UNIT_TEST_02' ext_entity = 'SCU_LM01' ext_entitled = 'PL_LM01' put_stra = 'PA10' ) ).
    lt_matlwhx =  VALUE #( ( ext_matnr = 'PROD_UNIT_TEST_01' ext_entity = 'SCU_LM01' ext_entitled = 'PL_LM01' put_stra = 'X' )
                           ( ext_matnr = 'PROD_UNIT_TEST_02' ext_entity = 'SCU_LM01' ext_entitled = 'PL_LM01' put_stra = 'X' ) ).

*   create 1 wh product and change 1 wh product
    CALL METHOD mo_cut->wh_prod_mass_change
      EXPORTING
        it_matkey          = lt_matkey
        it_matkeyx         = lt_matkeyx
        it_matlwh_create   = lt_matlwh_create
        it_matlwh_update   = lt_matlwh_update
        it_matlwhx         = lt_matlwhx
        it_matlwhst_create = lt_matlwhst_create
        it_matlwhst_update = lt_matlwhst_update
        it_matlwhstx       = lt_matlwhstx
      IMPORTING
        et_return          = lt_return
        ev_abort           = lv_abort
        ev_lines           = lv_lines
        ev_lines_st        = lv_lines_st.

    cl_aunit_assert=>assert_initial( act = lt_return ).
    cl_aunit_assert=>assert_initial( act = lv_abort ).
    cl_aunit_assert=>assert_equals( act = lv_lines exp = '2' ).
    cl_aunit_assert=>assert_equals( act = lv_lines_st exp = '0' ).


    CLEAR lt_matlwh_create.

    lt_matlwh_update =  VALUE #( ( method = 'C' ext_matnr = 'PROD_UNIT_TEST_01' ext_entity = 'SCU_LM01' ext_entitled = 'PL_LM01' )
                                 ( method = 'C' ext_matnr = 'PROD_UNIT_TEST_02' ext_entity = 'SCU_LM01' ext_entitled = 'PL_LM01' ) ).
    lt_matlwhst_create =  VALUE #( ( ext_matnr = 'PROD_UNIT_TEST_01' ext_entity = 'SCU_LM01' ext_entitled = 'PL_LM01' bintype = 'ABCD' ) ).
    lt_matlwhst_update =  VALUE #( ( ext_matnr = 'PROD_UNIT_TEST_02' ext_entity = 'SCU_LM01' ext_entitled = 'PL_LM01' bintype = 'ABCD' ) ).
    lt_matlwhstx =  VALUE #( ( ext_matnr = 'PROD_UNIT_TEST_01' ext_entity = 'SCU_LM01' ext_entitled = 'PL_LM01' bintype = 'X' )
                             ( ext_matnr = 'PROD_UNIT_TEST_02' ext_entity = 'SCU_LM01' ext_entitled = 'PL_LM01' bintype = 'X' )  ).



* create 1 whst and change 1 whst
    CALL METHOD mo_cut->wh_prod_mass_change
      EXPORTING
        it_matkey          = lt_matkey
        it_matkeyx         = lt_matkeyx
        it_matlwh_create   = lt_matlwh_create
        it_matlwh_update   = lt_matlwh_update
        it_matlwhx         = lt_matlwhx
        it_matlwhst_create = lt_matlwhst_create
        it_matlwhst_update = lt_matlwhst_update
        it_matlwhstx       = lt_matlwhstx
      IMPORTING
        et_return          = lt_return
        ev_abort           = lv_abort
        ev_lines           = lv_lines
        ev_lines_st        = lv_lines_st.

    cl_aunit_assert=>assert_initial( act = lt_return ).
    cl_aunit_assert=>assert_initial( act = lv_abort ).
    cl_aunit_assert=>assert_equals( act = lv_lines exp = '2' ).
    cl_aunit_assert=>assert_equals( act = lv_lines_st exp = '2' ).




    lt_matkey = VALUE #( ( method = 'C' ext_matnr = 'PROD_UNIT_TEST_03' )
                           ( method = 'C' ext_matnr = 'PROD_UNIT_TEST_05' ) ).
    lt_matkeyx = VALUE #( ( ext_matnr = 'PROD_UNIT_TEST_03' )
                           ( ext_matnr = 'PROD_UNIT_TEST_05' ) ).

    lt_matlwh_create =  VALUE #( ( ext_matnr = 'PROD_UNIT_TEST_03' ext_entity = 'SCU_LM01' ext_entitled = 'PL_LM01' put_stra = 'PA10' ) ).
    lt_matlwh_update =  VALUE #( ( ext_matnr = 'PROD_UNIT_TEST_05' ext_entity = 'SCU_LM01' ext_entitled = 'PL_LM01' put_stra = 'PA10' ) ).
    lt_matlwhx =  VALUE #( ( ext_matnr = 'PROD_UNIT_TEST_03' ext_entity = 'SCU_LM01' ext_entitled = 'PL_LM01' put_stra = 'X' )
                           ( ext_matnr = 'PROD_UNIT_TEST_05' ext_entity = 'SCU_LM01' ext_entitled = 'PL_LM01' put_stra = 'X' ) ).
    CLEAR lt_matlwhst_create.
    CLEAR lt_matlwhst_update.
    CLEAR lt_matlwhstx.

*   1 product can not be locked
    CALL METHOD mo_cut->wh_prod_mass_change
      EXPORTING
        it_matkey          = lt_matkey
        it_matkeyx         = lt_matkeyx
        it_matlwh_create   = lt_matlwh_create
        it_matlwh_update   = lt_matlwh_update
        it_matlwhx         = lt_matlwhx
        it_matlwhst_create = lt_matlwhst_create
        it_matlwhst_update = lt_matlwhst_update
        it_matlwhstx       = lt_matlwhstx
      IMPORTING
        et_return          = lt_return
        ev_abort           = lv_abort
        ev_lines           = lv_lines
        ev_lines_st        = lv_lines_st.

    cl_aunit_assert=>assert_initial( act = lt_return ).
    cl_aunit_assert=>assert_initial( act = lv_abort ).
    cl_aunit_assert=>assert_equals( act = lv_lines exp = '1' ).
    cl_aunit_assert=>assert_equals( act = lv_lines_st exp = '0' ).




    lt_matkey = VALUE #( ( method = 'C' ext_matnr = 'PROD_UNIT_TEST_04' )
                       ( method = 'C' ext_matnr = 'PROD_UNIT_TEST_05' ) ).
    lt_matkeyx = VALUE #( ( ext_matnr = 'PROD_UNIT_TEST_04' )
                           ( ext_matnr = 'PROD_UNIT_TEST_05' ) ).

    lt_matlwh_create =  VALUE #( ( ext_matnr = 'PROD_UNIT_TEST_04' ext_entity = 'SCU_LM01' ext_entitled = 'PL_LM01' put_stra = 'PA10' ) ).
    lt_matlwh_update =  VALUE #( ( ext_matnr = 'PROD_UNIT_TEST_05' ext_entity = 'SCU_LM01' ext_entitled = 'PL_LM01' put_stra = 'PA10' ) ).
    lt_matlwhx =  VALUE #( ( ext_matnr = 'PROD_UNIT_TEST_04' ext_entity = 'SCU_LM01' ext_entitled = 'PL_LM01' put_stra = 'X' )
                           ( ext_matnr = 'PROD_UNIT_TEST_05' ext_entity = 'SCU_LM01' ext_entitled = 'PL_LM01' put_stra = 'X' ) ).
    CLEAR lt_matlwhst_create.
    CLEAR lt_matlwhst_update.
    CLEAR lt_matlwhstx.

*   1 product can not be locked
    CALL METHOD mo_cut->wh_prod_mass_change
      EXPORTING
        it_matkey          = lt_matkey
        it_matkeyx         = lt_matkeyx
        it_matlwh_create   = lt_matlwh_create
        it_matlwh_update   = lt_matlwh_update
        it_matlwhx         = lt_matlwhx
        it_matlwhst_create = lt_matlwhst_create
        it_matlwhst_update = lt_matlwhst_update
        it_matlwhstx       = lt_matlwhstx
      IMPORTING
        et_return          = lt_return
        ev_abort           = lv_abort
        ev_lines           = lv_lines
        ev_lines_st        = lv_lines_st.

    cl_aunit_assert=>assert_initial( act = lt_return ).
    cl_aunit_assert=>assert_initial( act = lv_abort ).
    cl_aunit_assert=>assert_equals( act = lv_lines exp = '1' ).
    cl_aunit_assert=>assert_equals( act = lv_lines_st exp = '0' ).

  ENDMETHOD.







  METHOD get_styp_node_data.
    DATA: lt_data        TYPE /scwm/tt_prod_strg_mon_out,
          lt_matnr_range TYPE tt_matnr_range,
          ls_matnr_range TYPE ty_matnr_range,
          lv_lines       TYPE i.

* only products with whst data
    CALL METHOD mo_cut->get_styp_node_data
      EXPORTING
        iv_lgnum          = 'LM01'
        iv_lgtyp          = 'T010'
        it_matnr_range    = lt_matnr_range
        iv_only_with_whst = 'X'
      IMPORTING
        et_data           = lt_data.

    lv_lines = lines( lt_data ).
    cl_aunit_assert=>assert_equals( act = lv_lines exp = '1' ).

* only products with no whst data
    CALL METHOD mo_cut->get_styp_node_data
      EXPORTING
        iv_lgnum             = 'LM01'
        iv_lgtyp             = 'T010'
        it_matnr_range       = lt_matnr_range
        iv_only_without_whst = 'X'
      IMPORTING
        et_data              = lt_data.

    lv_lines = lines( lt_data ).
    cl_aunit_assert=>assert_equals( act = lv_lines exp = '1' ).

* both products with and without whst
    CALL METHOD mo_cut->get_styp_node_data
      EXPORTING
        iv_lgnum       = 'LM01'
        iv_lgtyp       = 'T010'
        it_matnr_range = lt_matnr_range
        iv_both        = 'X'
      IMPORTING
        et_data        = lt_data.

    lv_lines = lines( lt_data ).
    cl_aunit_assert=>assert_equals( act = lv_lines exp = '2' ).
  ENDMETHOD.
ENDCLASS.
