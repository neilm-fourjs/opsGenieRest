
IMPORT util
IMPORT FGL lib_opsgenie

-- Group Key used for sending alerts
DEFINE m_apiGroupKey STRING
-- Main key used for getting list of teams
DEFINE m_apiMainKey STRING

MAIN

	-- get the keys
	CALL lib_opsgenie.getAPIkeys("../keys.json") RETURNING m_apiGroupKey, m_apiMainKey

	DISPLAY ""
	CALL listTeams()

	DISPLAY ""
	CALL sendAlert()

END MAIN
--------------------------------------------------------------------------------
-- simple GET call to get a list of the 'Teams'
-- https://docs.opsgenie.com/docs/team-api#section-list-teams
FUNCTION listTeams()
	DEFINE l_json STRING
	DEFINE l_stat SMALLINT
	DEFINE l_reply RECORD -- record structure for reply from service
		data DYNAMIC ARRAY OF RECORD
			id STRING,
			name STRING
		END RECORD,
		took DECIMAL(6,3),
		requestId STRING
	END RECORD
	DEFINE x SMALLINT

	DISPLAY "Teams List:"

	-- do the api call using the Main key - Note: won't work with Group Key
	CALL lib_opsgenie.restCall("v2/teams", "", m_apiMainKey) RETURNING l_stat, l_json
	IF l_stat = 200 THEN -- 200 = Good
		-- convert json reply from call into a 4gl record
		CALL util.JSON.parse(l_json, l_reply)
		-- display teams
		FOR x = 1 TO l_reply.data.getLength()
			DISPLAY SFMT("Team Name: %1 ID: %2",l_reply.data[x].name, l_reply.data[x].id)
		END FOR
		DISPLAY SFMT("Request took %1, Id: %2",l_reply.took,l_reply.requestId)
	ELSE -- failed so just display the reply json string
		DISPLAY "Reply: ",l_stat,":",l_json
	END IF
END FUNCTION
--------------------------------------------------------------------------------
-- Post an alert to opsgenie 
-- https://docs.opsgenie.com/docs/alert-api
FUNCTION sendAlert()
	DEFINE l_json STRING
	DEFINE l_stat SMALLINT

	DEFINE l_message STRING
	DEFINE l_alias STRING
	DEFINE l_desc STRING
	DEFINE l_priority STRING

	DEFINE l_reply RECORD -- record structure for reply from service
		result STRING,
		took DECIMAL(6,3),
		requestId STRING
	END RECORD

-- setup the variables for the alert call
	LET l_message = "Test alert send "||CURRENT
	LET l_alias = "testonly"
	LET l_desc = "Sent via Genero test program"
	LET l_priority = "P5"

	DISPLAY "Alert Test:"
-- turn the variables into a json string that will be sent to the alert rest call
	LET l_json = lib_opsgenie.jsonAlert(l_message, l_alias, l_desc, l_priority)
	DISPLAY "Json:",l_json
	DISPLAY ""
-- do the rest call passing the json and use the Group key
	CALL lib_opsgenie.restCall("v2/alerts" , l_json, m_apiGroupKey) RETURNING l_stat, l_json
	IF l_stat = 202 THEN -- 202 - Accepted
		-- convert json reply from call into a 4gl record
		CALL util.JSON.parse(l_json, l_reply)
		-- display the reply
		DISPLAY SFMT("Result: %1", l_reply.result)
		DISPLAY SFMT("Request took %1, Id: %2",l_reply.took,l_reply.requestId)
	ELSE -- unexpect status, just display the json reply
		DISPLAY "Reply: ",l_stat,":",l_json
	END IF
END FUNCTION
