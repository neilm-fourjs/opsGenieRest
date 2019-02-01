
IMPORT util
IMPORT FGL lib_opsgenie

DEFINE m_opsGenie opsgenie = ( api_key_fileName: "../keys.json", service_host: "https://api.opsgenie.com/" )
MAIN

	CALL m_opsGenie.init()

	DISPLAY ""
	CALL listTeams()

	DISPLAY ""
--	CALL sendAlert()

END MAIN
--------------------------------------------------------------------------------
FUNCTION listTeams()
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
	CALL m_opsgenie.restCall("v2/teams" , "M")
	IF m_opsgenie.call_status = 200 THEN
		CALL util.JSON.parse(m_opsgenie.reply, l_reply)
		FOR x = 1 TO l_reply.data.getLength()
			DISPLAY SFMT("Team Name: %1 ID: %2",l_reply.data[x].name, l_reply.data[x].id)
		END FOR
		DISPLAY SFMT("Request took %1, Id: %2",l_reply.took,l_reply.requestId)
	ELSE
		DISPLAY "Reply: ",m_opsgenie.call_status,":",m_opsgenie.reply
	END IF
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION sendAlert()
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
	CALL m_opsgenie.sendAlert(l_message, l_alias, l_desc, l_priority)
	IF m_opsgenie.call_status = 202 THEN
		CALL util.JSON.parse(m_opsgenie.reply, l_reply)
		DISPLAY SFMT("Result: %1", l_reply.result)
		DISPLAY SFMT("Request took %1, Id: %2",l_reply.took,l_reply.requestId)
	ELSE
		DISPLAY "Reply: ", m_opsgenie.call_status,":",m_opsgenie.reply
	END IF
END FUNCTION