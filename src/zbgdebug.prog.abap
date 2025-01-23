*****           Implementation of object type ZBGDEBUG             *****
INCLUDE <OBJECT>.
BEGIN_DATA OBJECT. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
" begin of private,
"   to declare private attributes remove comments and
"   insert private attributes here ...
" end of private,
  BEGIN OF KEY,
      WORKPROCESS LIKE ZSTBC_BG_DEBUGGER_AUX-WP_INDEX,
  END OF KEY.
END_DATA OBJECT. " Do not change.. DATA is generated

BEGIN_METHOD OPENDEBUG CHANGING CONTAINER.
DATA: LV_WPNO TYPE WPINFO-WP_NO.
DATA: CL_SERVER_INFO TYPE REF TO CL_SERVER_INFO.
DATA: LT_WORK_LIST TYPE SSI_WORKER_LIST,
      LS_WORK_LIST LIKE LINE OF LT_WORK_LIST.
DATA: LC_EXIT(1) TYPE C.
DATA: LV_WORKER_INDEX TYPE SSI_WORKER_INDEX .
DATA: LV_SESSION_HDL TYPE INT1.
DATA: LV_WP_INDEX TYPE WPINFO-WP_INDEX.

*DO.
*  IF LC_EXIT = 'X'.
*     EXIT.
*  ENDIF.
*ENDDO.

*MESSAGE 'TESTE' TYPE 'X'.

LV_WPNO = OBJECT-KEY-WORKPROCESS.
LV_WORKER_INDEX = LV_WPNO.

TRY.
CREATE OBJECT cl_server_info
*  EXPORTING
*    server_name    =
    .
CATCH cx_ssi_no_auth .
ENDTRY.

TRY.
CALL METHOD cl_server_info->get_worker_list
   EXPORTING
*    with_cpu              = 0
*    with_application_info = 1
*    only_active_worker    = 0
     worker_index          = LV_WORKER_INDEX
  RECEIVING
    worker_list           = LT_WORK_LIST
    .
  CATCH cx_ssi_no_auth.
ENDTRY.

READ TABLE LT_WORK_LIST INTO LS_WORK_LIST INDEX 1.

LV_SESSION_HDL = LS_WORK_LIST-SESSION_HDL.

LV_WP_INDEX = LV_WPNO.
CALL FUNCTION 'TH_DEBUG_WP'
 EXPORTING
*   WP_NO                             = LV_WPNO
*   DEST                              = ' '
    WP_INDEX                          = LV_WP_INDEX
    LOGON_ID                          = LS_WORK_LIST-LOGON_ID
    SESSION_HDL                       = LV_SESSION_HDL
* IMPORTING
*   SUBRC                             =
 EXCEPTIONS
   NO_AUTHORITY                      = 1
   NO_DEBUGGING_POSSIBLE             = 2
   PARAMETER_ERROR                   = 3
   REQUEST_CHANGED                   = 4
   TOO_MANY_DEBUGGING_SESSIONS       = 5
   OTHERS                            = 6
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.

END_METHOD.
