# Marvel ComicBee

## Development Log
### Day 1
Quick brainstorm and initial observations on how to handle the requirements for the challenge.
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
- Comics can be easily obtainable by v1/public/comics
    - The attributes for sorting can be focDate or onsaleDate, maybe?
- A character list can be obtained by v1/public/characters and it is possible to search by character names starting with a string (more flexible search, does not need to be exact) 
- The comics that a specific character is in can be obtained by v1/public/characters/:character_id/comics

Made some API requests with insomnia to get familiar with the format. The main question now is how to synchronize this read-only API with the user preferences (the comics marked as favourite, for instance)