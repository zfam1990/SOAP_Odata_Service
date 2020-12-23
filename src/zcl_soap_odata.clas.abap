CLASS zcl_soap_odata DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_soap_odata IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA ls_response TYPE zce_soap_odata.
    DATA lt_response TYPE TABLE OF zce_soap_odata.

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
        DATA(ls_paging) = io_request->get_paging( ).
        TRY.
            DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).
          CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_range).
            RAISE EXCEPTION TYPE zcx_soap_exeption
              EXPORTING
                textid   = zcx_soap_exeption=>no_ranges
                previous = lx_no_range.
        ENDTRY.
        DATA(lv_filter) = lt_filter[ 1 ]-range[ 1 ]-low.

        DATA(request) = VALUE zget_product_soap_in1( product_id = lv_filter ).

        TRY.
            proxy->get_product(
              EXPORTING
                input = request
              IMPORTING
                output = DATA(response)
            ).

            ls_response = CORRESPONDING #( response-get_product_result ).

            APPEND  ls_response TO lt_response.

            io_response->set_data( lt_response ).

            IF io_request->is_total_numb_of_rec_requested( ).

              DATA(lv_number_of_records) = lines( lt_response ).

              io_response->set_total_number_of_records( iv_total_number_of_records = CONV #( lv_number_of_records ) ).
            ENDIF.

            IF io_request->is_data_requested(  ).
              io_response->set_data( lt_response ).
            ENDIF.

          CATCH cx_root INTO DATA(exception).
            DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).
        ENDTRY.
        "handle response
      CATCH cx_soap_destination_error.
        "handle error
      CATCH cx_ai_system_fault.
        "handle error
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
