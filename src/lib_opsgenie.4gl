
IMPORT util
IMPORT com

CONSTANT c_srv_host = "https://api.opsgenie.com/"

{ 
https://docs.opsgenie.com/docs/alert-api
Alert Fields
Field - Required - Description - Length
message: true - Message of the alert 130 characters
alias: false - Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.  512 characters
description: false - Description field of the alert that is generally used to provide a detailed information about the alert.  15000 characters
responders: false - Teams, users, escalations and schedules that the alert will be routed to send notifications. type field is mandatory for each item, where possible values are team, user, escalation and schedule. If the API Key belongs to a team integration, this field will be overwritten with the owner team. Either id or name of each responder should be provided.You can refer below for example values.  50 teams, users, escalations or schedules
visibleTo: false - Teams and users that the alert will become visible to without sending any notification.type field is mandatory for each item, where possible values are team and user. In addition to the type field, either id or name should be given for teams and either id or username should be given for users. Please note: that alert will be visible to the teams that are specified withinteams field by default, so there is no need to re-specify them within visibleTo field. You can refer below for example values.  50 teams or users in total
actions: false - Custom actions that will be available for the alert.  10 x 50 characters
tags: false - Tags of the alert.  20 x 50 characters
details: false - Map of key-value pairs to use as custom properties of the alert.  8000 characters in total
entity: false - Entity field of the alert that is generally used to specify which domain alert is related to.  512 characters
source: false - Source field of the alert. Default value is IP address of the incoming request.  100 characters.
priority: false - Priority level of the alert. Possible values are P1, P2, P3, P4 and P5. Default value is P3.  
user: false - Display name of the request owner.  100 characters.
note: false - Additional note that will be added while creating the alert.  25000 characters.
}
--------------------------------------------------------------------------------
-- Read the api keys from a json file
--
-- @param l_fileName The full path and name for the file
FUNCTION getAPIkeys(l_fileName STRING)
	DEFINE jsonText TEXT
	DEFINE l_rec RECORD
		mainAPIKey STRING,
		groupAPIKey STRING
	END RECORD
	LOCATE jsonText IN MEMORY
	TRY
		CALL jsonText.readFile(l_fileName)
	CATCH
		DISPLAY SFMT("Failed to get API keys file '%1'!", l_fileName)
		EXIT PROGRAM
	END TRY
	TRY
		CALL util.JSON.parse( jsonText, l_rec)
	CATCH
		DISPLAY "Failed to parse API keys file!"
		EXIT PROGRAM
	END TRY
	RETURN l_rec.groupAPIKey, l_rec.mainAPIKey
END FUNCTION
--------------------------------------------------------------------------------
-- Build the JSON string for the alert body
--
-- @param l_msg The title for the alert ( required )
-- @param l_alias The alias field
-- @param l_desc The Description text for the alert
-- @param l_pri The Priority ( P1 - P5 )
FUNCTION jsonAlert( l_msg STRING, l_alias STRING, l_desc STRING,l_pri STRING)
	DEFINE l_o util.JSONObject

	LET l_o = util.JSONObject.create()
	CALL l_o.put("message",l_msg)
	CALL l_o.put("alias",l_alias)
	CALL l_o.put("description",l_desc)
	CALL l_o.put("source", "GeneroTest")
	CALL l_o.put("priority", l_pri)

	RETURN l_o.toString()
END FUNCTION
--------------------------------------------------------------------------------
-- Make REST Call to the opsGenie rest server
--
-- @param l_url The rest url excluding the hostname part
-- @param l_data The data to POST - if NULL assumes doing a GET
-- @param l_apiKey The API Key
FUNCTION restCall(l_url STRING, l_data STRING, l_apiKey STRING)
	DEFINE l_req com.HttpRequest
	DEFINE l_resp com.HttpResponse
	DEFINE l_status SMALLINT

	DISPLAY "Calling: "||c_srv_host||l_url
	LET l_req = com.HttpRequest.Create(c_srv_host||l_url)
	IF l_data.getLength() > 1 THEN
		CALL l_req.setMethod("POST")
		CALL l_req.setHeader("Content-Type", "application/json")
	ELSE
		CALL l_req.setMethod("GET")
	END IF

	CALL l_req.setHeader("Accept", "application/json")
	CALL l_req.setHeader("Authorization", "GenieKey "||l_apiKey)

	IF l_data.getLength() > 1 THEN
		CALL l_req.doTextRequest( l_data )
	ELSE
		CALL l_req.doRequest()
	END IF

	LET l_resp = l_req.getResponse()
	LET l_status = l_resp.getStatusCode()

	RETURN l_status, l_resp.getTextResponse()
END FUNCTION
--------------------------------------------------------------------------------
