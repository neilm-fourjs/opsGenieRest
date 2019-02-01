
# opsGenie demo program for REST API calls


Requires the api keys to be in a file called keys.json that looks like this
```
{
	"mainApiKey": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
	"groupApiKey": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}
```


Expected result on running:
```
Group API Key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
Main API Key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

Teams List:
Calling: https://api.opsgenie.com/v2/teams
Team Name: Sup SXB ID: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Team Name: Genero Cloud ID: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Request took 0.003, Id: c85502af-583b-404f-bc2f-0fdb81929a8d

Alert Test:
Json:{"message":"Test alert send 2019-02-01 11:49:13.746","alias":"testonly","description":"Sent via Genero test program","source":"GeneroTest","priority":"P5"}

Calling: https://api.opsgenie.com/v2/alerts
Result: Request will be processed
Request took 0.009, Id: 77261acb-d812-43a4-a0a9-22969ca43d1d
```
