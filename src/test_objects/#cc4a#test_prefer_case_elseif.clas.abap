CLASS /cc4a/test_prefer_case_elseif DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS with_elseif_chain.
    METHODS with_pseudo_comment.
ENDCLASS.



CLASS /cc4a/test_prefer_case_elseif IMPLEMENTATION.
  METHOD with_elseif_chain.
    DATA(type) = 'A'.
    IF type = 'A'.
      DATA(result) = 1.
    ELSEIF type = 'B'.
      result = 2.
    ELSEIF type = 'C'.
      result = 3.
    ELSEIF type = 'D'.
      result = 4.
    ELSEIF type = 'E'.
      result = 5.
    ENDIF.
  ENDMETHOD.

  METHOD with_pseudo_comment.
    DATA(type) = 'A'.
    IF type = 'A'.                                     "#EC PREFER_CASE
      DATA(result) = 1.
    ELSEIF type = 'B'.
      result = 2.
    ELSEIF type = 'C'.
      result = 3.
    ELSEIF type = 'D'.
      result = 4.
    ELSEIF type = 'E'.
      result = 5.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

