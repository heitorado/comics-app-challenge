# Marvel ComicBee
## Running the project
Standard rails setup. Built with Ruby 2.7.4 and Rails 6.1.4.

### 1. Setup the database:
```bash
rails db:setup
```
### 2. Set up environment variables and credentials
Set up the required environment variables and credentials at `credentials.yml.enc`:
First, run:
```bash
# You can change to other editor if you do not like vim :)
EDITOR=vim rails credentials:edit
```

The file should look like this:
```yml
marvel_api:
  url: https://gateway.marvel.com:443/v1/public
  public_key: your_super_secret_public_key
  private_key: your_super_secret_private_key

secret_key_base: something_default_provided_by_rails
```

### 3. Start the application server
```bash
rails s
```

## Running tests
All tests are written in minitest. To run them, simply execute:
```
rails test:all
```


# Development Log
### 🗓 Day 1
Quick planning/brainstorm and initial observations on how to handle the requirements for the challenge.
Must have:
- Service layer to handle communication with Marvel's API.
- Pagination, since Marvel certainly has a huge number of comics.
- The default ordering of comics should be from newest to oldest
- Users should be able to search by character
- Users should be able to mark comics as favourite
- Users should be able to upvote on comics which will increase its popularity
- Users should be able to sort comics by popularity
- Automated tests
- Simple cookie based session, at least

Optional:
- Users can filter comics to display only the ones they marked as favourite
- User authentication
- Deploy on Heroku

Observations:
- Comics can be easily obtainable by `v1/public/comics`
    - The attributes for sorting can be `focDate` or `onsaleDate`, maybe?
- A character list can be obtained by `v1/public/characters` and it is possible to search by character names starting with a string (more flexible search, does not need to be exact) 
- The comics that a specific character is in can be obtained by `v1/public/characters/:character_id/comics`

Made some API requests with insomnia to get familiar with the format. The main question now is how to synchronize this read-only API with the user preferences (the comics marked as favourite, for instance)

### 🗓 Day 2
#### 🕘 Part 1
As for how to synchronize the objects retrieved by the API with the application-specific attributes, it seems that [ActiveResource](https://github.com/rails/activeresource) has what I need, or maybe [Her](https://github.com/remi/her).
Those might be a bit of overkill though, since the API is read only and just the comics will need to be marked as favourite. It would strongly bind the application to the API structure, which _might_ make it future-proof but also increase coupling a lot.

~~Quick~~ (at day 3 realized it wasn't so quick) solution: Build a wrapper from scratch and then think how to deal with setting/retrieving the favourite comics for the User later?

#### 🕘 Part 2
Initialized fresh Rails app today.
Installed `rest-client` gem
Started coding marvel api wrapper
Added marvel api credentials to the encrypted credentials file.

#### 🕘 Part 3
The API wrapper is looking good so far. Marvel's API has its own way to deal with images, so I can't just retrieve the raw value from the payload and put into the HTML. I think it is a good idea to create a 'Comic' [value object](https://martinfowler.com/bliki/ValueObject.html) so the API wrapper returns them instead of the raw JSON payload.

#### 🕘 Part 4
Built a service to consume the interface defined by the API wrapper. This service is responsible to build 'Comic' objects from the payload obtained from the wrapper.
The main idea here is that the wrapper just cares about accessing the API and returning the JSON payload. Inside the wrapper are also defined some constants as per the API documentation (thumbnail sizes, for instance). So the wrapper is ignorant about the existance of everything else in the application. It just has the rules for acessing the api, the means to access it, and returns the raw JSON as a ruby hash.
The service, on the other side, acts as a glue layer between the controller and the wrapper, but it is also ignorant about what the controller does. It just knows how to call the wrapper, process the raw hash payload into 'Comic' objects and send them back. The controller now has easy-to use wrapped objects with useful information to populate the views.

#### 🕘 Part 5
Sorting was a bit of a headache. Spent several hours trying to understand some inconsistencies on the API. First, I'm assuming that the parameter that has to be sorted is the `'onsaleDate'` since this is the parameter used by the official Marvel website for the "published at" date. Problems:
- This was an url that came in one of the API responses for a comic: https://www.marvel.com/comics/issue/3627/storm_2006?utm_campaign=apiRef&utm_source=07e3e205bebd46de31d15ee9a76d85c2. Accessing it, the title says the comic is from 2006, but the "Published" says "December 31, 2029". There are a couple of other comics with years such as 2029 and 2099.
- Some comics have this weird release date and also a lot of other comics with different ids associated to it, called "variants". From those variants, though, very few have a cover image, as can be seen here: https://www.marvel.com/comics/issue/59739/civil_war_ii_kingpin_2016_1_noto_character_variant/noto_character_variant?utm_campaign=apiRef&utm_source=07e3e205bebd46de31d15ee9a76d85c2
- I though about excluding from the response comics that were with a release date after the current day, but that would not solve the problem. After some investigation on the ordered response that came from the API, there still are some inconsistencies between the published date and the title of the comic itself: https://www.marvel.com/comics/issue/84362/avengers_2018_44. This one has "(2018)" in the title but the Marvel website says it was published in April 7th, 2021. The release date is the same for all its variants as well.

There are two interesting request parameters that I could use:
- `formatType` (can be comic or collection, I would set it to 'comic')
- `noVariants` (bool, if false no variants would be shown, only the original comic issue)

#### 🕘 Part 6
Ended up configuring those additional parameters to increase the quality of the response as much as I could. Also configured the dateRange attribute to return comics released only before/on the present day. Enhanced the interface between the service and the wrapper, allowing the parameters to be overriden if necessary.

Started working on the layout to take a break from the back end. Found [this tool](https://imagecolorpicker.com/en) which helped me quickly find the colors used. Also learned about [flexbox](https://css-tricks.com/snippets/css/a-guide-to-flexbox) and I am positively surprised on how easy it was to replicate the design with it, just took a few css lines.

Also learned how to do the nice hover effect for each comic cover to display its title thanks to [this video](https://www.youtube.com/watch?v=exb2ab72Xhs). [CSS Tricks](https://css-tricks.com) was a blessing once again for many things css related as well.

Added the assets to the main project and finished the basic initial layout of the comics listing page, with logo and search box.

### 🗓 Day 3
#### 🕘 Part 1
Implemented the search box logic, which allows to search by character. Added extra endpoint on the API and a Character value object.
When searching by character, the `/characters` API endpoint is queried using the `'nameStartsWith'` option, to give more flexibility when searching (does not require an exact match). The number of characters returned can be more than one, so the Character objects are created for each one of the characters - this way we can easily access the ID after and insert the list of IDs when querying for comics using the `'characters'` query parameter.
- The problem with this approach is that only 10 IDs can be passed at a time in the 'characters' parameter. So if more than 10 matching characters are found, not all of them would be used to query for comics. Although 10 characters _might_ be sufficient to track the most relevant characters that match the input string, there could be a user-frustrating corner case there.
- Another approach would be to iterate through all Characters and obtain the complete list of comics which is provided in the payload. However, that would add an extra complexity to filter the comics, while on the previous approach the query does it directly with the character IDs.

#### 🕘 Part 2
Pagination implemented. Just added some environment variables which are populated after every call to ComicsService, indicating the current page and the last page. These variables allowed me to define helpers that tell the view when to render the appropriate buttons. Some styling here and there, and it was done.

Spent some time thinking and researching about the simple cookie based session + the favourites feature. I was thinking that since no user management was present, this would be an application without any models. But not really. Learned that it is not good to store lots of things in a cookie, so the cookie can have just the primary key of a database record which I can retrieve and update freely. That would allow me to keep track of the favourited comics.
When thinking about that and about the external rate limiting that the Marvel API could apply, I had the idea of using Redis. With redis I could easily store the favourited comics for each user session, easily purge them after 30 minutes and also keep the already fetched comics in cache for some time, which would drastically reduce the number of queries made to the API (currently one each time a new page loads, and two every time the search box is used)

However, it would add some complexity to run my code afterwards (installing redis, setting up the server/port) and I want to avoid crazy steps for running this project. Redis is canceled for now, then.

Took a deeper look at memcached, which is pretty cool but still requires an external server. MemoryStore will probably do the job for this application, since we do not intend to run multiple instances of it.


### 🗓 Day 4
#### 🕘 Part 1
The '30 minute based session' is still a little bit confusing to me. So the user can favourite the comics all the way she wants, but then if it becomes inactive for more than 30 minutes or closes the browser window, the cookie expires and there goes all the favourites? The only other way I can think of persisting the chosen favourites would be to add an user management/auth system, which is out of scope for this project. So I'm assuming that yeah, after 30 minutes all the favourites set will be gone forever.

The plan for implementing the favourites logic is as follow:
- create a model to store the IDs of the comics favourited by the user
- store the ID of that model in the session cookie
- every time a user favourites/unfavourites a comic, fetch and update the model
- when rendering a comic, check if its ID is present on the model referenced by the session cookie. Using a hash will improve the search performance.

Might have to think of a background task to delete jobs which wasn't updated for more than a given period of time, say, 30 minutes (which is the session time).

#### 🕘 Part 2
Favourites logic implemented. It was a little bit difficult to get the AJAX request/response right, I'm kinda rusty at this. Also, took a long time to discover that the [AJAX/UJS callback signature changed](https://stackoverflow.com/a/46555801) and the value I was sending back was encapsulated into a specific field - hours thinking I was doing something wrong, but just looking at the wrong place. Needed to look a lot into the jQuery documentation (and also on how to install jQuery - webpacker is a whole new world to me). Doing the styling / DOM manipulation to toggle the heart states was really fun and interesting. Front end is not my strongest skill when it comes to web development, so it is always nice to learn more and exercise it. [This guide](https://medium.com/@codenode/how-to-use-remote-true-to-make-ajax-calls-in-rails-3ecbed40869b) really helped me as a general guide on how to deal with AJAX requests and remote forms. Also learned about Rails [button_to](https://api.rubyonrails.org/v6.1.4/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to) helper which is really neat.

Basic caching implemented as well! Never had done that in a Rails app before and it was fun to learn and experiment with. The profiler results were very positive, sometimes I had a reduction from **12.000ms** on the first request to **50ms** on the subsequent request! It will also help to deal with external rate limiting from the Marvel API.
Used a combination of the method parameters as the cache key - this way I ensure that if there are any changes in the request parameters, a new request will be made and cached afterwards.
The 15 minute cache expiration was a totally arbitrary decision. I do not know the frequency that Marvel updates' their comics, so I just took a wild guess that 15 minutes would be a reasonable amount of time to assume that the data being consumed was going to be the same - but the sweet spot might be more or less than that. The more we increase the expiration time, the less requests we make, but more out-of-sync we get with the official API.
  
To wrap up for today, just added some basic styling for the favourites button - Still needs some polishing and I would like to click on the whole comic to set it as a favourite. Currently, you have to click exactly on the heart to favourite / unfavourite.

### 🗓 Day 5
Many tweaks on the front end. Edited the heart images so they are all the same size now, so it does not seem like the heart is moving when toggling the favourite on a comic. Also added the outlines and some dynamic classes to highlight the favourited comics.

Did some polishing on the navbar, changed the default search button for a custom styled one, and made the "Marvel" logo clickable, redirecting to the root url of the application.

Did some code cleanup, renaming, moved some methods to places where I think they would belong/fit better. Added comments and also rescued from possible RestClient exceptions that might happen if something goes awry when connecting to the Marvel API.
Fixed a bug where if the searched character was not found, the default comics list was loaded - instead, switched to not showing any comics at all and displaying a message suggesting a new search with different words.

Added an background job dedicated to cleaning up inactive users and a rake task to trigger it. That rake task can be easily invoked in a production environment with any scheduling tool such as cron. A nice gem to deal with that is the [whenever](https://github.com/javan/whenever) gem. I do not plan on configuring the scheduled task for that since that might vary depending on the production environment (Heroku has its own scheduler, for instance) - but the rake task and background job are done. Another arbitrary decision for user removal: An user is considered inactive if the model was not updated in the last 2 days.

Started (and finished) writing tests! Decided to not write tests for the API wrapper since they can get messy and complicated, and I do not have much time left. With more time I would make some custom matchers (or switch to rspec) to test if the format of the JSON payload we receive from the API matches our expectations - that way the application's tests would be sensible to changes in that payload, and allow us to detect breaking changes quickly.

For testing, added the [mocha](https://github.com/freerange/mocha) gem for mocking, which is really nice and makes testing a lot easier, especially in this case where we depend a lot on an external application and it is not a good idea to have tests to be dependent on internet connection and make real API calls. 