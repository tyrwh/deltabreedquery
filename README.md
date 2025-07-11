# Running notes on deltabreedquery
### Tyr Wiesner-Hanks
### 2025-07-10

### NAMING
Not sure what makes the most sense, but deltabreedquery is a fine placeholder for now. If this ends up being useful to other people besides me, could name it deltabreed_r or just deltabreed or something, whatever.

### PRINCIPLES

1. The output should match the naming and formatting of data as it appears on DeltaBreed whenever possible.
2. All human-readable information associated with a given data type should be included by default and all non-human readable info should be excluded by default.
3. No spaces or special characters in column headers - use CamelCase instead

### OVERALL WORKFLOW


### LOGGING IN

Supplying the url/access token isn't technically logging in, but it seems reasonable to just use this language. Users are used to 

Do you have a URL specified?
- If so

Response code could use some specific messaging to help people with common mistakes they might be making
- 200: it's good
- 404 or 500: check that the URL is correct
- 401: check that the token matches the URL, try regenerating a token

### QUERYING

Which endpoints would you want to query?
- Ontology
- Germplasm
- Experiments (trials, studies, etc)
- ObservationUnits
- Observations

There are two ways to make an API request:
1. GET a query with or without specified
2. POST a search query to a search endpoint


Separating these out into two function types seems useful:
1. get_xyz() to just pull all the data for a given data type
2. search_xyz() to pass search terms as lists

You could allow for people to pass commands into get, but I'm not sure if that's much faster tbh

Every get/search should have a checkpoint for 404/401 error and supply a helpful error message if possible



### PAGE SIZE

From some basic testing, I haven't seen any noticeable time difference between a request with pageSize=500 and one with pageSize=50. 

The higher the page size, the fewer calls you have to send. Thus, the overall time for a request scales inversely with the page size. 

I assume you could run into timeout issues or something if you set the pageSize too high. This is worth testing though.

For now, I'm using a default pageSize of 1000. It's a nice round number.


### TRAITS

The most common use case is probably to pull all traits, since most people have a manageable number of traits (10s, rarely >100) in their program. 

Would you ever need to search it? Probably not often, but it makes sense to implement a Search functionality all the same.

The nomenclature gets a bit confusing. The frontend calls it Ontology, but in terms of BrAPI-compliant endpoints, the core data is stored on the /variables endpoint, not /ontology or /traits. For simplicity, I'm calling it "traits"

I couldn't figure out where the full text descriptions of each trait were stored. Maybe this is in a non-BrAPI endpoint? Either way, I'm skipping this for now.


Match the appearance of the Ontology table in DeltaBreed, but add in the stuff from the "Show details" pane as well.



### GERMPLASM
Nothing super fancy here. Just match the appearance of the table exactly.

How do you pull pedigrees? I think that is a different task altogether.


### EXPERIMENTS

Both BrAPI and DeltaBreed use two levels of experimental data, one larger one and one smaller one:

TYPE		BRAPI		DELTABREED
Large		Trials		Experiments
Small		Studies	Environments

BrAPI treats the small entity (Study) as the core one while the larger (Trial) is more just a flexible grouping level. DeltaBreed does the opposite - the larger entity (Experiment) is the core unit, while the smaller one (Environment) is just a subset of this.

The nomenclature around trial and study is too complex to deal with fully. Instead, just pull everything into a single "experiments" entity.

What does the large entity (Trials / Experiments) contain?
- trialDescription - NOT ALWAYS PRESENT
- trialName
- additionalInfo.experimentType
- additionalInfo.defaultObservationLevel

What does the smaller entity (Studies / Environments) contain?
- studyName
- studyType
- locationName
- trialName
- seasons [DbId pointer]

What other info might you want to get, which might require a query to other endpoints?
- Num Unique germplasm entries
- Num ObservationUnits
- Num Traits
- Num Observations
- 

I think this can all be pulled from ObsUnits and Observations??



### OBSERVATIONS

Observation Units (the plots, plants, trees, etc. and their physical layout) are stored separately from actual Observations (the height, yield, disease resistance, etc. that are taken on these units).

I think it's pretty rare few people want to pull Observation Units without their corresponding Observations. It could be 

So I don't feel like that should be supported tbh.




What do you get from ObservationUnits?
- germplasmName			GermplasmName
- studyName				Environment
- trialName				Experiment
- locationName			EnvLocation
- observationUnitName		ExpUnitID
- observationUnitPosition.entryType		TestOrCheck


What do you get from Observations?
- additionalInfo.createdBy
- additionalInfo.studyName (matches Env)
- additionalinfo.createdDate
* observationVariableName
* observationUnitName
* germplasmName
* value
- studyDbId
- germplasmDbId
- observationVariableDbId
- observationUnitDbId


What do you want in the output?
NOTE : This is the ordering as viewed in DeltaBreed. I don't like the first three columns, since it violates the basic principle of organizing data, that the leftmost columns should contain the most general grouping factors and the rightmost columns should contain the most specific. 

Moving the germplasm columns mostly fixes this though.

- GermplasmName (move)
- GID (move)
- TestOrCheck (move)
- ExpTitle
- ExpDescription
- ExpUnit
- ExpType
- EnvName
- EnvLocation
- EnvYear
- ExpUnitID
- Replicate
- Block
- Row
- Column
- Lat
- Long
- Elevation
- RTK
- Treatment Factors
- ObsUnitID
- all the phenotypes
















