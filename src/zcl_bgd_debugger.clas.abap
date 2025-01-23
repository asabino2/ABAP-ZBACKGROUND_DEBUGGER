class ZCL_BGD_DEBUGGER definition
  public
  final
  create public .

public section.

  class-methods DEBUG
    importing
      !DESCRIPTION type CLIKE optional
      !NOTIFIER type SY-UNAME default SY-UNAME
      !TIMEOUT type I default 300 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_BGD_DEBUGGER IMPLEMENTATION.


  method DEBUG.
   DATA: LT_CALLSTACK TYPE ABAP_CALLSTACK.
   DATA: LS_CALLSTACK LIKE LINE OF LT_CALLSTACK.
   DATA: LS_ZTBC_BGDEBUG_SP TYPE ZTBC_BGDEBUG_SP,
         LS_ZTBC_BGDEBUG_SPT TYPE ZTBC_BGDEBUG_SPT.
   DATA: LN_LINE(6) TYPE N.
   DATA: LC_WPINDEX(30) TYPE C.
   DATA: LI_WPINDEX TYPE WPINFO-WP_INDEX.
   DATA: LN_TIMESTAMP1(14) TYPE N,
         LN_TIMESTAMP2(14) TYPE N.
   DATA: LI_TIMESTAMP1 TYPE CCUPEAKA-TIMESTAMP,
         LI_TIMESTAMP2 TYPE CCUPEAKA-TIMESTAMP.
   DATA: LI_DIFFERENCE TYPE I.
   DATA: LC_EXIT(1) TYPE C.
   DATA: LS_TEXTINFO TYPE SOTXTINFO.
   DATA: LS_PROCESS_PARAM TYPE SOPROCPAR.
   DATA: LT_REC_TAB TYPE TABLE OF SOOS7,
         LS_REC_TAB LIKE LINE OF LT_REC_TAB.
    CALL FUNCTION 'SYSTEM_CALLSTACK'
*     EXPORTING
*       MAX_LEVEL          = 0
      IMPORTING
        CALLSTACK          = LT_CALLSTACK
*       ET_CALLSTACK       =
              .

  READ TABLE LT_CALLSTACK INTO LS_CALLSTACK INDEX 2.
  LN_LINE = LS_CALLSTACK-LINE.
*  CONDENSE LC_LINE NO-GAPS.



  DO.
    IF SY-INDEX = 1.
       GET TIME.
       CONCATENATE SY-DATUM SY-UZEIT INTO LN_TIMESTAMP1.
       LI_TIMESTAMP1 = LN_TIMESTAMP1.

       CALL FUNCTION 'TH_GET_OWN_WP_NO'
         IMPORTING
*          SUBRC          =
*          WP_NO          =
*          WP_PID         =
           WP_INDEX       = LI_WPINDEX
                 .

      LC_WPINDEX = LI_WPINDEX.
      CONDENSE LC_WPINDEX NO-GAPS.

       SELECT SINGLE *
              INTO LS_ZTBC_BGDEBUG_SP
              FROM ZTBC_BGDEBUG_SP
              WHERE MAINPROGRAM = LS_CALLSTACK-MAINPROGRAM AND
                    INCLUDE = LS_CALLSTACK-INCLUDE AND
                    LINE = LN_LINE.

      IF LS_ZTBC_BGDEBUG_SP-ACTIVE IS INITIAL.
         IF SY-SUBRC <> 0.
            LS_ZTBC_BGDEBUG_SP-MANDT = SY-MANDT.
            LS_ZTBC_BGDEBUG_SP-MAINPROGRAM = LS_CALLSTACK-MAINPROGRAM.
            LS_ZTBC_BGDEBUG_SP-INCLUDE = LS_CALLSTACK-INCLUDE.
            LS_ZTBC_BGDEBUG_SP-LINE = LN_LINE.
            MODIFY ZTBC_BGDEBUG_SP FROM LS_ZTBC_BGDEBUG_SP.

            IF DESCRIPTION IS NOT INITIAL.
               LS_ZTBC_BGDEBUG_SPT-MANDT = SY-MANDT.
               LS_ZTBC_BGDEBUG_SPT-MAINPROGRAM = LS_CALLSTACK-MAINPROGRAM.
               LS_ZTBC_BGDEBUG_SPT-INCLUDE = LS_CALLSTACK-INCLUDE.
               LS_ZTBC_BGDEBUG_SPT-LINE = LN_LINE.
               LS_ZTBC_BGDEBUG_SPT-SPRAS = SY-LANGU.
               LS_ZTBC_BGDEBUG_SPT-KTEXT = DESCRIPTION.
               MODIFY ZTBC_BGDEBUG_SP FROM LS_ZTBC_BGDEBUG_SP.
            ENDIF.
         ENDIF.
         EXIT.
      ELSE.
         LS_TEXTINFO-MSGID = 'ZBC_BGD_DEBUGGER'.
         LS_TEXTINFO-MSGNO = '001'.
         LS_TEXTINFO-MSGV1 = LS_CALLSTACK-MAINPROGRAM.
         LS_TEXTINFO-MSGV2 = LS_CALLSTACK-INCLUDE.
         LS_TEXTINFO-MSGV3 = LN_LINE.


         LS_PROCESS_PARAM-OBJTYPE = 'ZBGDEBUG'.
         LS_PROCESS_PARAM-OBJKEY = LC_WPINDEX.
         LS_PROCESS_PARAM-METHOD = 'OPENDEBUG'.

         LS_REC_TAB-RECNAM = NOTIFIER.
         LS_REC_TAB-RECESC = 'B'.
         APPEND LS_REC_TAB TO LT_REC_TAB.

         CALL FUNCTION 'SO_EXPRESS_FLAG_SET'
           EXPORTING
             CLIENT                   = SY-MANDT
             TEXT_INFO                = LS_TEXTINFO
             PROCESS_PARAM            = LS_PROCESS_PARAM
*            PROCDIRECT               = 'X'
*            SINGLENTRY               = ' '
*            INBOX                    = 'X'
*            POPUP_TITLE              = ' '
*            PERIOD_OF_VALIDITY       = '00000000'
*            CALL_AT_ONCE             = 'X'
*          IMPORTING
*            SENT_TO_ALL              =
           TABLES
             rec_tab                  = LT_REC_TAB
          EXCEPTIONS
            NO_RECEIVER_EXIST        = 1
            OFFICE_NAME_ERROR        = 2
            OTHERS                   = 3
                   .
         IF sy-subrc <> 0.
* Implement suitable error handling here
         ENDIF.

      ENDIF.
    ENDIF.
       GET TIME.
       CONCATENATE SY-DATUM SY-UZEIT INTO LN_TIMESTAMP2.
       LI_TIMESTAMP2 = LN_TIMESTAMP2.
       CALL FUNCTION 'CCU_TIMESTAMP_DIFFERENCE'
         EXPORTING
           timestamp1       = LI_TIMESTAMP2
           timestamp2       = LI_TIMESTAMP1
         IMPORTING
           DIFFERENCE       = LI_DIFFERENCE
                 .

       IF LI_DIFFERENCE > TIMEOUT OR LC_EXIT = 'X'.
          EXIT.
       ENDIF.

  ENDDO.

  endmethod.
ENDCLASS.
