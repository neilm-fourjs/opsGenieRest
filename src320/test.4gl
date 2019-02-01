
IMPORT util
IMPORT FGL lib_opsgenie

DEFINE m_opsGenie opsgenie = ( api_key_fileName: "../keys.json",	service_host: "https://api.opsgenie.com/" )
MAIN

	CALL m_opsGenie.init()

	DISPLAY ""
	CALL listTeams()

	DISPLAY ""
	CALL sendAlert()

END MAIN
--------------------------------------------------------------------------------
FUNCTION listTeams()
	DEFINE l_json STRING
	DEFINE l_stat SMALLINT
	DEFINE l_url STRING
	DEFINE l_reply RECORD
		data DYNAMIC ARRAY OF RECORD
			id STRING,
			name STRING
		END RECORD,
		took DECIMAL(6,3),
		requestId STRING
	END RECORD
	DEFINE x SMALLINT

	DISPLAY "Teams List:"
	LET l_url = "v2/teams"
	LET l_json = ""
	CALL m_opsgenie.restCall(l_url, l_json, "M") RETURNING l_stat, l_json
	IF l_stat = 200 THEN
		CALL util.JSON.parse(l_json, l_reply)
		FOR x = 1 TO l_reply.data.getLength()
			DISPLAY SFMT("Team Name: %1 ID: %2",l_reply.data[x].name, l_reply.data[x].id)
		END FOR
		DISPLAY SFMT("Request took %1, Id: %2",l_reply.took,l_reply.requestId)
	ELSE
		DISPLAY "Reply:",l_stat,":",l_json
	END IF
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION sendAlert()
	DEFINE l_json STRING
	DEFINE l_stat SMALLINT
	DEFINE l_url STRING

	DEFINE l_message STRING
	DEFINE l_alias STRING
	DEFINE l_desc STRING
	DEFINE l_priority STRING

	DEFINE l_reply RECORD
		result STRING,
		took DECIMAL(6,3),
		requestId STRING
	END RECORD

	LET l_message = "Test alert "||CURRENT
	LET l_alias = "test320"
	LET l_desc = "Sent via Genero 3.20 test program"
	LET l_priority = "P5"

	DISPLAY "Alert Test:"
	LET l_json = m_opsgenie.jsonAlert(l_message, l_alias, l_desc, l_priority)
	DISPLAY "Json:",l_json
	DISPLAY ""
	LET l_url = "v2/alerts"
	CALL m_opsgenie.restCall(l_url, l_json, "G") RETURNING l_stat, l_json
	IF l_stat = 202 THEN
		CALL util.JSON.parse(l_json, l_reply)
		DISPLAY SFMT("Result: %1", l_reply.result)
		DISPLAY SFMT("Request took %1, Id: %2",l_reply.took,l_reply.requestId)
	ELSE
		DISPLAY "Reply:",l_stat,":",l_json
	END IF
END FUNCTION