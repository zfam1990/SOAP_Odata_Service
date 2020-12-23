@EndUserText.label: 'Custom entity for new service'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_NEW_SERVICE'
@UI: {
  headerInfo: { typeName: 'Business Partner', typeNamePlural: 'Business Partner', title: { type: #STANDARD, value: 'BusinessPartner' } } }


@Search.searchable: true
define custom entity ZCE_NEW_SERVICE1
{
  @UI: {
              lineItem:       [ { position: 10, label: 'Business Partner', importance: #HIGH } ],
              identification: [ { position: 10, label: 'Business Partner' } ],
              selectionField: [ { position: 10 } ] }
  @Search.defaultSearchElement: true
  key BusinessPartner              : abap.char( 10 );  
      
      @UI: {
              lineItem:       [ { position: 20, label: 'Business Partner Name', importance: #HIGH } ],
              identification: [ { position: 20, label: 'Business Partner Name' } ],
              selectionField: [ { position: 20 } ] }
  @Search.defaultSearchElement: true
      BusinessPartnerName          : abap.char( 81 );
      @UI: {
              lineItem:       [ { position: 30, label: 'Product ID', importance: #HIGH } ],
              identification: [ { position: 30, label: 'Product ID' } ],
              selectionField: [ { position: 30 } ] }
  @Search.defaultSearchElement: true
      BusinessPartnerIDByExtSystem : abap.char( 20 );
      @UI: {
              lineItem:       [ { position: 40, label: 'Product Name', importance: #HIGH } ],
              identification: [ { position: 40, label: 'Product Name' } ],
              selectionField: [ { position: 40 } ] }
  @Search.defaultSearchElement: true

      name                         : abap.string(0);

}
