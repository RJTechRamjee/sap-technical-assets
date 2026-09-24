@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Billing Document Item Extension - Interface'
@Metadata.allowExtensions: true

// Demo artefact for COE Session 02.
// Its only job here is to exist so that the `applyTo: '**/*.asddls'` glob in
// .github/instructions/cds-views.instructions.md has something to match.
//
// Selects from this project's own extension table. In a real build this would
// join the released billing document interface view --
// [CONFIRM in ADT: check the API State tab for the released view name before
// using one. Do not take a plausible-looking name from generated output.]

define view entity ZI_BillingDocItemExt
  as select from zbill_item_ext
{
  key billing_document       as BillingDocument,
  key billing_document_item  as BillingDocumentItem,

      @EndUserText.label: 'Settlement Group'
      settlement_group       as SettlementGroup,

      @EndUserText.label: 'Deferred Revenue Flag'
      deferred_revenue       as DeferredRevenue,

      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText.label: 'Accrued Amount'
      accrued_amount         as AccruedAmount,

      @Semantics.currencyCode: true
      @EndUserText.label: 'Currency'
      currency               as Currency,

      @Semantics.user.createdBy: true
      created_by             as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at             as CreatedAt,

      @Semantics.user.lastChangedBy: true
      last_changed_by        as LastChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at        as LastChangedAt
}
