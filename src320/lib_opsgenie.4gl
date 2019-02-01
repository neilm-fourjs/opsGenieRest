
IMPORT util
IMPORT com

PUBLIC TYPE opsgenie RECORD
		service_host STRING,
		api_key_fileName STRING,
		api_main_key STRING,
		api_group_key STRING,
		data STRING,
		call_status SMALLINT,
		reply STRING
	END RECORD

{ Alert Fields
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
FUNCTION (this opsgenie) init()
	DEFINE jsonText TEXT
	DEFINE l_rec RECORD
		mainAPIKey STRING,
		groupAPIKey STRING
	END RECORD
	LOCATE jsonText IN MEMORY
	TRY
		CALL jsonText.readFile(this.api_key_fileName)
	CATCH
		DISPLAY SFMT("Failed to get API keys file '%1'!", this.api_key_fileName)
		EXIT PROGRAM
	END TRY
	TRY
		CALL util.JSON.parse( jsonText, l_rec)
	CATCH
		DISPLAY "Failed to parse API keys file!"
		EXIT PROGRAM
	END TRY
	LET this.api_group_key = l_rec.groupAPIKey
	LET this.api_main_key = l_rec.mainAPIKey

	DISPLAY "Service Host:", this.service_host
	DISPLAY "Group API Key: ", this.api_group_key
	DISPLAY "Main API Key: ", this.api_main_key

END FUNCTION
--------------------------------------------------------------------------------
-- Build the JSON string for the alert body
--
-- @param l_msg The title for the alert ( required )
-- @param l_alias The alias field
-- @param l_desc The Description text for the alert
-- @param l_pri The Priority ( P1 - P5 )
FUNCTION (this opsgenie) sendAlert( l_msg STRING, l_alias STRING, l_desc STRING,l_pri STRING)
	DEFINE l_o util.JSONObject

	LET l_o = util.JSONObject.create()
	CALL l_o.put("message",l_msg)
	CALL l_o.put("alias",l_alias)
	CALL l_o.put("description",l_desc)
	CALL l_o.put("source", "GeneroTest")
	CALL l_o.put("priority", l_pri)

	LET this.data = l_o.toString()

	DISPLAY "Data:", this.data

	CALL this.restCall("v2/alerts", "G")
END FUNCTION
--------------------------------------------------------------------------------
-- Make REST Call to the opsGenie rest server
--
-- @param l_url The rest url excluding the hostname part
-- @param l_keyType The API Key "M" or "G"
FUNCTION (this opsgenie) restCall(l_url STRING, l_keyType CHAR(1))
	DEFINE l_req com.HttpRequest
	DEFINE l_resp com.HttpResponse
	DEFINE l_status SMALLINT
	DEFINE l_apiKey STRING

	LET l_apiKey = IIF(l_keyType = "G", this.api_group_key, this.api_main_key )

	DISPLAY SFMT("Calling: %1",this.service_host||l_url)
	LET l_req = com.HttpRequest.Create(this.service_host||l_url)
	IF this.data.getLength() > 1 THEN
		CALL l_req.setMethod("POST")
		CALL l_req.setHeader("Content-Type", "application/json")
	ELSE
		CALL l_req.setMethod("GET")
	END IF

	CALL l_req.setHeader("Accept", "application/json")
	CALL l_req.setHeader("Authorization", "GenieKey "||l_apiKey)

	IF this.data.getLength() > 1 THEN
		CALL l_req.doTextRequest( this.data )
	ELSE
		CALL l_req.doRequest()
	END IF

	LET l_resp = l_req.getResponse()
	LET this.reply = l_resp.getTextResponse()
	LET this.call_status = l_resp.getStatusCode()
END FUNCTION
--------------------------------------------------------------------------------