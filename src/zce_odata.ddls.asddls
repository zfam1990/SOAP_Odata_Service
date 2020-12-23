@EndUserText.label: 'Custom entity for odata service'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_ODATA'
@UI: {
  headerInfo: { typeName: 'BusinessPartner', typeNamePlural: 'BusinessPartners', title: { type: #STANDARD, value: 'BusinessPartner' } } }


//@Search.searchable: true
define custom entity ZCE_ODATA
{
  key BusinessPartner              : abap.char( 10 );
      BusinessPartnerName          : abap.char( 81 );
      BusinessPartnerIDByExtSystem : abap.char( 20 );



}
