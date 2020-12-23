CLASS zcl_new_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_new_service IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    "Data  for Odata service

    DATA: lt_business_data TYPE TABLE OF za_businesspartner2145461cb9,
          lo_http_client   TYPE REF TO if_web_http_client,
          lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
          lo_request       TYPE REF TO /iwbep/if_cp_request_read_list,
          lo_response      TYPE REF TO /iwbep/if_cp_response_read_lst.

    DATA: lo_filter_factory           TYPE REF TO /iwbep/if_cp_filter_factory,
          lo_filter_for_current_field TYPE REF TO /iwbep/if_cp_filter_node,
          lo_filter                   TYPE REF TO /iwbep/if_cp_filter_node,
          lt_select_properties        TYPE /iwbep/if_cp_runtime_types=>ty_t_property_path,
          lv_filter_property          TYPE /iwbep/if_cp_runtime_types=>ty_property_path,
          ls_business_data1           TYPE zce_new_service,
          lt_business_data1           TYPE TABLE OF zce_new_service.
    DATA(sort_order)    = io_request->get_sort_elements( ).



    "Request for Soap service

    DATA ls_response TYPE zce_soap_odata.
    DATA lt_response TYPE TABLE OF zce_soap_odata.
    TRY.
        "Request for Odata service
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

        lo_request = lo_client_proxy->create_resource_for_entity_set( 'A_BUSINESSPARTNER' )->create_request_for_read( ).

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
          IF <fs_filter>-name = 'BUSINESSPARTNER' OR
             <fs_filter>-name = 'BUSINESSPARTNERNAME' OR
             <fs_filter>-name = 'BUSINESSPARTNERIDBYEXTSYSTEM'.

            lo_filter_for_current_field  = lo_filter_factory->create_by_range( iv_property_path     = <fs_filter>-name
                                                                               it_range             = <fs_filter>-range ).

            IF lo_filter IS INITIAL.
              lo_filter = lo_filter_for_current_field.
            ELSE.
              lo_filter = lo_filter->and( lo_filter_for_current_field ).
            ENDIF.
          ENDIF.
        ENDLOOP.

        IF lo_filter IS NOT INITIAL.
          lo_request->set_filter( lo_filter ).
        ENDIF.

        IF io_request->is_data_requested( ) = abap_false.
          lo_request->request_no_business_data(  ).
        ENDIF.

        DATA(lt_req_elements) = io_request->get_requested_elements( ).


        LOOP AT lt_req_elements ASSIGNING FIELD-SYMBOL(<lt_req_elements>).
          IF <lt_req_elements> = 'BUSINESSPARTNER' OR
             <lt_req_elements> = 'BUSINESSPARTNERNAME' OR
             <lt_req_elements> = 'BUSINESSPARTNERIDBYEXTSYSTEM'.
            APPEND <lt_req_elements> TO lt_select_properties.
          ENDIF.
        ENDLOOP.

        lo_request->set_select_properties( it_select_property =  lt_select_properties ).

        lo_response = lo_request->execute( ).

        IF io_request->is_data_requested( ).
          lo_response->get_business_data( IMPORTING et_business_data = lt_business_data ).
        ENDIF.

        "Request for SOAP service
        TRY.
            DATA(destination) = cl_soap_destination_provider=>create_by_url(
                     i_url = 'https://soapapi.webservicespros.com/soapapi.asmx' ).

            destination->set_soap_action(
            i_action = 'http://tempuri.org/GetProduct'
            i_operation = 'GetProduct'
             ).

            DATA(proxy) = NEW zco_soap_api_soap1(
                            destination = destination
                          ).

            LOOP AT lt_business_data ASSIGNING FIELD-SYMBOL(<fs_business_data>).

              DATA(lv_filter) = lt_business_data[ businesspartner = <fs_business_data>-businesspartner ]-businesspartneridbyextsystem.

              FIND ALL OCCURRENCES OF REGEX '[0-9]'
                                         IN lv_filter
                                    RESULTS DATA(lv_result).

              IF lv_result IS NOT INITIAL.


                DATA(request) = VALUE zget_product_soap_in1( product_id = lv_filter ).


                proxy->get_product(
                  EXPORTING
                    input = request
                  IMPORTING
                    output = DATA(response)
                ).

                IF response IS NOT INITIAL.

                  ls_business_data1 = CORRESPONDING #( <fs_business_data> ).
                  ls_business_data1-name = response-get_product_result-name.
                  APPEND  ls_business_data1 TO lt_business_data1.
                ENDIF.

              ENDIF.
            ENDLOOP.

            IF io_request->is_data_requested(  ).
              io_response->set_data( lt_business_data1 ).
            ENDIF.

            IF io_request->is_total_numb_of_rec_requested( ).
              DATA(lv_number_of_records) = lines( lt_business_data1 ).
              io_response->set_total_number_of_records( iv_total_number_of_records = CONV #( lv_number_of_records ) ).
            ENDIF.

          CATCH cx_soap_destination_error.
            "handle error
          CATCH cx_ai_system_fault.
            "handle error
        ENDTRY.

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
    ENDTRY.

  ENDMETHOD.
  METHOD if_oo_adt_classrun~main.

    TRY.
        DATA(destination) = cl_soap_destination_provider=>create_by_url(
                 i_url = 'https://soapapi.webservicespros.com/soapapi.asmx' ).

        destination->set_soap_action(
        i_action = 'http://tempuri.org/GetProduct'
        i_operation = 'GetProduct'
         ).

        DATA(proxy) = NEW zco_soap_api_soap1(
                        destination = destination
                      ).

        DATA(request) = VALUE zget_product_soap_in1( product_id = '3106' ).


        proxy->get_product(
          EXPORTING
            input = request
          IMPORTING
            output = DATA(response)
        ).
      CATCH cx_soap_destination_error.
        "handle error
      CATCH cx_ai_system_fault INTO DATA(lx_error).

        out->write( lx_error->errortext ).
        "handle error
    ENDTRY.

    out->write( response-get_product_result-color ).


  ENDMETHOD.
ENDCLASS.
