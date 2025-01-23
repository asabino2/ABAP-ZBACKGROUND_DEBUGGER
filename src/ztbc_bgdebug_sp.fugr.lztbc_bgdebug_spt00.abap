*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTBC_BGDEBUG_SP.................................*
DATA:  BEGIN OF STATUS_ZTBC_BGDEBUG_SP               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTBC_BGDEBUG_SP               .
CONTROLS: TCTRL_ZTBC_BGDEBUG_SP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTBC_BGDEBUG_SP               .
TABLES: *ZTBC_BGDEBUG_SPT              .
TABLES: ZTBC_BGDEBUG_SP                .
TABLES: ZTBC_BGDEBUG_SPT               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
