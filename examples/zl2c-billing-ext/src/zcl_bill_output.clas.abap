" Demo artefact for COE Session 02.
" Exists so the `applyTo: '**/*.clas.abap'` glob in
" .github/instructions/abap-clean-core.instructions.md has something to match.
"
" Written to be *compliant* rather than clever: ABAP Cloud language version,
" no obsolete statements, typed exceptions, short methods, no magic literals.
" Try asking Copilot to extend it -- the scoped rules ride along automatically.

CLASS zcl_bill_output DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_accrual,
        billing_document      TYPE zbill_item_ext-billing_document,
        billing_document_item TYPE zbill_item_ext-billing_document_item,
        accrued_amount        TYPE zbill_item_ext-accrued_amount,
        currency              TYPE zbill_item_ext-currency,
      END OF ty_accrual,
      ty_accruals TYPE STANDARD TABLE OF ty_accrual WITH EMPTY KEY.

    METHODS calculate_accruals
      IMPORTING items         TYPE ty_accruals
      RETURNING VALUE(result) TYPE ty_accruals.

    METHODS total_for_currency
      IMPORTING items         TYPE ty_accruals
                currency      TYPE zbill_item_ext-currency
      RETURNING VALUE(result) TYPE zbill_item_ext-accrued_amount
      RAISING   cx_abap_invalid_value.

  PRIVATE SECTION.
    CONSTANTS deferral_rate TYPE p LENGTH 5 DECIMALS 4 VALUE '0.1500'.

    METHODS apply_deferral
      IMPORTING amount        TYPE zbill_item_ext-accrued_amount
      RETURNING VALUE(result) TYPE zbill_item_ext-accrued_amount.
ENDCLASS.


CLASS zcl_bill_output IMPLEMENTATION.

  METHOD calculate_accruals.
    result = VALUE #( FOR item IN items
                      ( billing_document      = item-billing_document
                        billing_document_item = item-billing_document_item
                        accrued_amount        = apply_deferral( item-accrued_amount )
                        currency              = item-currency ) ).
  ENDMETHOD.


  METHOD total_for_currency.
    IF currency IS INITIAL.
      RAISE EXCEPTION NEW cx_abap_invalid_value( ).
    ENDIF.

    result = REDUCE #( INIT sum = VALUE zbill_item_ext-accrued_amount( )
                       FOR item IN items
                       WHERE ( currency = currency )
                       NEXT sum = sum + item-accrued_amount ).
  ENDMETHOD.


  METHOD apply_deferral.
    result = amount * ( 1 - deferral_rate ).
  ENDMETHOD.

ENDCLASS.
