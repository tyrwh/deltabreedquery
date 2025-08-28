# deltabreedquery


This is a small R package to pull data from Breeding Insight's [DeltaBreed](https://sandbox.breedinginsight.net/) platform into R via [BrAPI](https://brapi.org/) calls. It offers some basic functions to pull four types of data into a properly formatted data frame:

- Germplasm
- Traits (aka ontology terms, phenotype terms)
- Experiments/Environments (aka Trials, Studies)
- Observations (aka )

For each data type, there are two functions: one which sends a GET request to fetch all the data of the given type (e.g. `get_germplasm()`) and one which sends a POST request to search for specific terms (e.g. `search_observations(year = 2024)`).

For most purposes, fetching everything via `get_x()` will be the more useful method. For one, searching in BrAPI can only be done via exact string matching as of September 2025. There are no Boolean operators that would allow you to request all experimental data where `Year > 2017`, for example. What's more, for programs without a ton of records, it doesn't take that long to just pull all the data, after which you can filter it however you like. 

Searching is still useful for programs with a large amount of data on DeltaBreed obviously, or if you want to build a more minimal workflow (e.g. writing a field season summary that draws data from specific years).

You can easily allow for people to pass specific search terms into a GET query, but I'm not sure if that's much faster than using a search query. [Search services in BrAPI](https://plant-breeding-api.readthedocs.io/en/latest/docs/best_practices/Search_Services.html) are pretty optimized as it is.

### NAMING
`deltabreedquery` was just a placeholder name, to be honest. If this ends up being useful to other people besides me we could name it `deltabreed_r` or just `deltabreed` or something, whatever.

### PRINCIPLES

I used a few basic design principles in writing this:

1. Fetched data should be returned as a tidy data frame that resembles the data as it appears in DeltaBreed itself.
2. If a naming convention would cause problems in R (spaces, special characters), using unambiguous CamelCase names takes precedent over copying DeltaBreed conventions exactly.
3. All human-readable information associated with a given data type should be included by default, and all non-human readable info should be excluded by default; no `DbId`s in the data frame.

### LOGGING IN

To "log in", you need to get a valid Access Token from within DeltaBreed and supply it once, after which it's stored in the `deltabreedquery` global env. I know this isn't logging in *per se*, but it seems better to use this language for simplicity's sake. Since access tokens expire after 24 hours, it's vaguely analogous to logging in.

`logout_deltabreed()` does the reverse. All it does is remove the URL and token from your global env.

### QUERYING

There are several 
- Ontology
- Germplasm
- Experiments (trials, studies, etc)
- ObservationUnits
- Observations

Every get/search should have a checkpoint for 404/401 error and supply a helpful error message if possible.

### PAGINATION

Most endpoints allow for pagination, as far as I can tell. Only some of them allow you to adjust the page size by appending `?pageSize=x`, however.

From some rudimentary testing, I haven't seen any noticeable time difference between a request with `pageSize=500` and one with `pageSize=50`. The overall time for a request scales inversely with the page size, since the larger the pageSize, the more individual calls you have to make.

I assume you could run into timeout issues or something if you set the page size too high. This is probably worth testing or asking the Breeding Insight dev team. For now, I'm using the default `pageSize` of 1000. It's a nice round number.

### TRAITS

The nomenclature for traits gets a bit confusing. The frontend calls it Ontology, but in terms of BrAPI endpoints, the core data is stored on the `/variables` endpoint, not `/ontology` or `/traits`. For simplicity, I've just called it "Traits" throughout.

The most common use case is probably to just pull all traits, since most people have a manageable number of traits (10s, rarely >100) in their program. It seems rarer that you'd want to search traits for a specific reason.

The Ontology table in DeltaBreed captures most of the core info, but I've also added in a few things (min, max, category levels) from the "Show details" pane as well.

*Note:* I couldn't figure out where the full text descriptions of each trait were stored. Maybe this is in a non-BrAPI endpoint? Either way, I'm skipping this for now.

### GERMPLASM

Nothing super fancy here. Just match the appearance of the table exactly.

How do you pull pedigrees? I think that is a different task altogether.


### EXPERIMENTS

Both BrAPI and DeltaBreed use two levels of experimental data, one larger one and one smaller one:

| TYPE  | BRAPI      | DELTABREED |
| ----  | ----       | ---- |
|Large  | Trials		| Experiments |
|Small	| Studies	  | Environments |

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
















