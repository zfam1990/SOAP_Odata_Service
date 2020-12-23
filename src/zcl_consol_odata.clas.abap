CLASS zcl_consol_odata DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_consol_odata IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA: ls_entity_key    TYPE za_businesspartner,
          ls_business_data TYPE za_businesspartner,
          lo_http_client   TYPE REF TO if_web_http_client,
          lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
          lo_resource      TYPE REF TO /iwbep/if_cp_resource_entity,
          lo_request       TYPE REF TO /iwbep/if_cp_request_read,
          lo_response      TYPE REF TO /iwbep/if_cp_response_read.



    TRY.
        lo_http_client = cl_web_http_client_manager=>create_by_http_destination(
                                 cl_http_destination_provider=>create_by_url(
                                 i_url = 'https://my303843.s4hana.ondemand.com/sap/opu/odata/sap'
                                  ) ).



        lo_client_proxy = cl_web_odata_client_factory=>create_v2_remote_proxy(
          EXPORTING
            iv_service_definition_name = 'ZSC_ODATA'
            io_http_client             = lo_http_client
            iv_relative_service_root   = '/sap/opu/odata/sap/API_BUSINESS_PARTNER/' ).


        " Set entity key
        ls_entity_key = VALUE #(
                            businesspartner = '1000000'
                         ).


        " Navigate to the resource
        lo_resource = lo_client_proxy->create_resource_for_entity_set( 'A_BUSINESSPARTNER' )->navigate_with_key( ls_entity_key ).

        " Execute the request and retrieve the business data
        lo_response = lo_resource->create_request_for_read( )->execute( ).
        lo_response->get_business_data( IMPORTING es_business_data = ls_business_data ).

         out->write( ls_business_data-businesspartnerfullname  ).

      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
        " Handle remote Exception
        " It contains details about the problems of your http(s) connection

      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        " Handle Exception

ENDTRY.
      ENDMETHOD.
ENDCLASS.
