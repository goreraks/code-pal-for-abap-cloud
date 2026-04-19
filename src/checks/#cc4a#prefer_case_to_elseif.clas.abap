CLASS /cc4a/prefer_case_to_elseif DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_ci_atc_check.

    CONSTANTS:
      BEGIN OF finding_codes,
        prefer_case TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_CASE',
      END OF finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS pseudo_comment TYPE string VALUE 'PREFER_CASE'.
    CONSTANTS threshold       TYPE i      VALUE 5.

    TYPES:
      BEGIN OF ty_stack_entry,
        if_stmt_index TYPE i,
        if_stmt       TYPE if_ci_atc_source_code_provider=>ty_statement,
      END OF ty_stack_entry.

    TYPES:
      BEGIN OF ty_chain,
        if_stmt_index  TYPE i,
        if_stmt        TYPE if_ci_atc_source_code_provider=>ty_statement,
        condition_root TYPE string,
        count          TYPE i,
      END OF ty_chain.

    DATA code_provider     TYPE REF TO if_ci_atc_source_code_provider.
    DATA assistant_factory TYPE REF TO cl_ci_atc_assistant_factory.
    DATA meta_data         TYPE REF TO /cc4a/if_check_meta_data.

    METHODS analyze_procedure
      IMPORTING procedure       TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(findings) TYPE if_ci_atc_check=>ty_findings.

    METHODS has_multiple_conditions
      IMPORTING statement     TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(result) TYPE abap_bool.

    METHODS get_condition_root
      IMPORTING statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(root) TYPE string.
ENDCLASS.



CLASS /cc4a/prefer_case_to_elseif IMPLEMENTATION.


  METHOD constructor.
    meta_data = /cc4a/check_meta_data=>create(
      VALUE #( checked_types     = /cc4a/check_meta_data=>checked_types-abap_programs
               description       = 'Prefer CASE to ELSE IF'(des)
               remote_enablement = /cc4a/check_meta_data=>remote_enablement-unconditional
               finding_codes     = VALUE #(
                 ( code           = finding_codes-prefer_case
                   pseudo_comment = pseudo_comment
                   text           = 'Prefer CASE to ELSE IF for multiple alternative conditions!'(pce) ) ) ) ).
  ENDMETHOD.


  METHOD if_ci_atc_check~run.
    code_provider = data_provider->get_code_provider( ).
    DATA(procedures) = code_provider->get_procedures( code_provider->object_to_comp_unit( object ) ).
    LOOP AT procedures->* ASSIGNING FIELD-SYMBOL(<procedure>).
      INSERT LINES OF analyze_procedure( <procedure> ) INTO TABLE findings.
    ENDLOOP.
  ENDMETHOD.


  METHOD if_ci_atc_check~get_meta_data.
    meta_data = me->meta_data.
  ENDMETHOD.


  METHOD if_ci_atc_check~set_assistant_factory.
    assistant_factory = factory.
  ENDMETHOD.


  METHOD if_ci_atc_check~set_attributes ##NEEDED.
  ENDMETHOD.


  METHOD if_ci_atc_check~verify_prerequisites.
  ENDMETHOD.


  METHOD analyze_procedure.
    DATA stack  TYPE STANDARD TABLE OF ty_stack_entry WITH EMPTY KEY.
    DATA chains TYPE STANDARD TABLE OF ty_chain       WITH EMPTY KEY.

    LOOP AT procedure-statements ASSIGNING FIELD-SYMBOL(<stmt>).
      DATA(idx) = sy-tabix.

      CASE <stmt>-keyword.

        WHEN 'IF'.
          INSERT VALUE #( if_stmt_index = idx if_stmt = <stmt> ) INTO TABLE stack.
          IF has_multiple_conditions( <stmt> ) = abap_false.
            DATA(root) = get_condition_root( <stmt> ).
            IF root IS NOT INITIAL.
              INSERT VALUE #( if_stmt_index  = idx
                              if_stmt        = <stmt>
                              condition_root = root
                              count          = 1 ) INTO TABLE chains.
            ENDIF.
          ENDIF.

        WHEN 'ELSEIF'.
          IF stack IS NOT INITIAL.
            DATA(top) = stack[ lines( stack ) ].
            IF has_multiple_conditions( <stmt> ) = abap_false.
              DATA(elseif_root) = get_condition_root( <stmt> ).
              IF elseif_root IS NOT INITIAL.
                TRY.
                    chains[ if_stmt_index  = top-if_stmt_index
                            condition_root = elseif_root ]-count += 1.
                  CATCH cx_sy_itab_line_not_found.
                    INSERT VALUE #( if_stmt_index  = top-if_stmt_index
                                    if_stmt        = top-if_stmt
                                    condition_root = elseif_root
                                    count          = 1 ) INTO TABLE chains.
                ENDTRY.
              ENDIF.
            ENDIF.
          ENDIF.

        WHEN 'ENDIF'.
          IF stack IS NOT INITIAL.
            DATA(popped) = stack[ lines( stack ) ].
            DELETE stack INDEX lines( stack ).

            LOOP AT chains ASSIGNING FIELD-SYMBOL(<chain>) ##PRIMKEY[IF_STMT_INDEX]
                WHERE if_stmt_index = popped-if_stmt_index
                  AND count >= threshold.
              INSERT VALUE #(
                code               = finding_codes-prefer_case
                location           = code_provider->get_statement_location( <chain>-if_stmt )
                checksum           = code_provider->get_statement_checksum( <chain>-if_stmt )
                has_pseudo_comment = meta_data->has_valid_pseudo_comment(
                  statement    = <chain>-if_stmt
                  finding_code = finding_codes-prefer_case )
              ) INTO TABLE findings.
              EXIT.
            ENDLOOP.

            DELETE chains WHERE if_stmt_index = popped-if_stmt_index.
          ENDIF.

      ENDCASE.
    ENDLOOP.
  ENDMETHOD.


  METHOD has_multiple_conditions.
    LOOP AT statement-tokens ASSIGNING FIELD-SYMBOL(<token>)
        WHERE lexeme = 'AND' OR lexeme = 'OR'.
      result = abap_true.
      RETURN.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_condition_root.
    TRY.
        root = statement-tokens[ 2 ]-lexeme.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
  ENDMETHOD.


ENDCLASS.
