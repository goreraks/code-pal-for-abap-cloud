CLASS /cc4a/test_prefer_case_elseif2 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS below_threshold.
    METHODS mixed_conditions.
ENDCLASS.



CLASS /cc4a/test_prefer_case_elseif2 IMPLEMENTATION.
  METHOD below_threshold.
    DATA(type) = 'A'.
    IF type = 'A'.
      DATA(result) = 1.
    ELSEIF type = 'B'.
      result = 2.
    ELSEIF type = 'C'.
      result = 3.
    ELSEIF type = 'D'.
      result = 4.
    ENDIF.
  ENDMETHOD.

  METHOD mixed_conditions.
    DATA(type) = 'A'.
    DATA(status) = 'X'.
    IF type = 'A' AND status = 'X'.
      DATA(result) = 1.
    ELSEIF type = 'B' AND status = 'Y'.
      result = 2.
    ELSEIF type = 'C' AND status = 'Z'.
      result = 3.
    ELSEIF type = 'D' AND status = 'W'.
      result = 4.
    ELSEIF type = 'E' AND status = 'V'.
      result = 5.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

