CLASS zcl_odata DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_odata IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA: lt_business_data TYPE TABLE OF ZA_BUSINESSPARTNER2145461CB9,
          lo_http_client   TYPE REF TO if_web_http_client,
          lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
          lo_request       TYPE REF TO /iwbep/if_cp_request_read_list,
          lo_response      TYPE REF TO /iwbep/if_cp_response_read_lst.

    DATA: lo_filter_factory           TYPE REF TO /iwbep/if_cp_filter_factory,
          lo_filter_for_current_field TYPE REF TO /iwbep/if_cp_filter_node,
          lo_filter                   TYPE REF TO /iwbep/if_cp_filter_node,
          lt_select_properties        TYPE /iwbep/if_cp_runtime_types=>ty_t_property_path,
          lv_filter_property          TYPE /iwbep/if_cp_runtime_types=>ty_property_path.
    DATA(sort_order)    = io_request->get_sort_elements( ).
    "      lo_filter_node_root TYPE REF TO /iwbep/if_cp_filter_node,
    "      lt_range_businesspartner TYPE RANGE OF <element_name>,
    "      lt_range_customer TYPE RANGE OF <element_name>.


    TRY.
        " Create http client
        " Details depend on your connection settings
        TRY.
            lo_http_client = cl_web_http_client_manager=>create_by_http_destination(
                                     cl_http_destination_provider=>create_by_url(
                                     i_url = 'https://my303843.s4hana.ondemand.com' ) ).

            lo_http_client->get_http_request( )->set_authorization_basic(
                   i_username = 'POSTMAN_TEST_USER'
                   i_password = 'cZmFDcXiqJpLXEFVlKghcuNMiaYkuVamSMf~U5fQ').

          CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
            RAISE EXCEPTION TYPE zcx_soap_exeption
              EXPORTING
                textid   = zcx_soap_exeption=>remote_access_failed
                previous = lx_http_dest_provider_error.


          CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
            RAISE EXCEPTION TYPE zcx_soap_exeption
              EXPORTING
                textid   = zcx_soap_exeption=>remote_access_failed
                previous = lx_web_http_client_error.

        ENDTRY.
        TRY.
            lo_client_proxy = cl_web_odata_client_factory=>create_v2_remote_proxy(
              EXPORTING
                iv_service_definition_name = 'ZSC_ODATA1'
                io_http_client             = lo_http_client
                iv_relative_service_root   = '/sap/opu/odata/sap/API_BUSINESS_PARTNER/' ).
          CATCH cx_web_http_client_error INTO lx_web_http_client_error.
            RAISE EXCEPTION TYPE zcx_soap_exeption
              EXPORTING
                textid   = zcx_soap_exeption=>client_proxy_failed
                previous = lx_web_http_client_error.
        ENDTRY.
        " Navigate to the resource and create a request for the read operation

        lo_request = lo_client_proxy->create_resource_for_entity_set( 'A_BUSINESSPARTNER' )->create_request_for_read( ).

        """Request Count
        IF io_request->is_total_numb_of_rec_requested( ).
          lo_request->request_count( ).
        ENDIF.

        """Request Data
        IF io_request->is_data_requested( ).

          """Request Paging
          "Skip
          DATA(ls_paging) = io_request->get_paging( ).
          IF ls_paging->get_offset( ) >= 0.
            lo_request->set_skip( ls_paging->get_offset( ) ).
          ENDIF.
          "Top
          IF ls_paging->get_page_size( ) <> if_rap_query_paging=>page_size_unlimited.
            lo_request->set_top( ls_paging->get_page_size( ) ).
          ENDIF.
        ENDIF.

        TRY.
            DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).
          CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_range).
            RAISE EXCEPTION TYPE zcx_soap_exeption
              EXPORTING
                textid   = zcx_soap_exeption=>no_ranges
                previous = lx_no_range.
        ENDTRY.

        lo_filter_factory = lo_request->create_filter_factory( ).

        LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<fs_filter>).
          " Create the filter tree

          lo_filter_for_current_field  = lo_filter_factory->create_by_range( iv_property_path     = <fs_filter>-name
                                                                             it_range             = <fs_filter>-range ).
          "lo_filter_node_2  = lo_filter_factory->create_by_range( iv_property_path     = 'customer'
          "                                                        it_range             = lt_range_customer ).
          "lo_filter_node_root = lo_filter_node_1->and( lo_filter_node_2 ).
          "
          "lo_request->set_filter( lo_filter_node_root ).

          IF lo_filter IS INITIAL.
            lo_filter = lo_filter_for_current_field.
          ELSE.
            lo_filter = lo_filter->and( lo_filter_for_current_field ).
          ENDIF.
        ENDLOOP.

        IF lo_filter IS NOT INITIAL.
          lo_request->set_filter( lo_filter ).
        ENDIF.

        IF io_request->is_data_requested( ) = abap_false.
          lo_request->request_no_business_data(  ).
        ENDIF.

        """Request Elements
        DATA(lt_req_elements) = io_request->get_requested_elements( ).

        LOOP AT lt_req_elements ASSIGNING FIELD-SYMBOL(<fs_req_elements>).

        ENDLOOP.

        lt_select_properties = CORRESPONDING #( lt_req_elements ).
        lo_request->set_select_properties( it_select_property =  lt_select_properties ).

        " Execute the request and retrieve the business data
        lo_response = lo_request->execute( ).

        IF io_request->is_data_requested( ).
          lo_response->get_business_data( IMPORTING et_business_data = lt_business_data ).
        ENDIF.
        """Set Count
        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lo_response->get_count( ) ).
        ENDIF.

        """Set Data
        IF io_request->is_data_requested( ).
          io_response->set_data( lt_business_data ).
        ENDIF.

      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
        RAISE EXCEPTION TYPE zcx_soap_exeption
          EXPORTING
            textid   = zcx_soap_exeption=>http_connection_failed
            previous = lx_remote.
        " Handle remote Exception
        " It contains details about the problems of your http(s) connection


      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        RAISE EXCEPTION TYPE zcx_soap_exeption
          EXPORTING
            textid   = zcx_soap_exeption=>query_failed
            previous = lx_gateway.
        " Handle Exception

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
