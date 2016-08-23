# eSports Initiative - Involvement Fair SignUp App

Creates a **.csv** file of form entries. With the following format:

```csv
 First Name, Last Name, .#, Email, Event Organization (ESI Staff), Competitive Play (Teams / Management / Coaching), Casual Play (Attend Events), CS:GO, League of Legends, Dota 2, Smash - Melee, Smash - PM, Smash - 4, Smash - Other, Hearthstone, StarCraft 2, Overwatch, Call of Duty, FIFA, Madden, NBA 2K
```

## Making executables

Make the `.exe`'s by installing the development environment (specified below) and running `npm run build`. Distribute the resulting files with contain the `.exe`.

### Caveats

The location of the generated `.csv` is currently hardcoded. Please change it in `js/csv.js` (When in executable form `resources/app/js/csv.js`)

## To Further Develop

To clone and run this repository you'll need [Git](https://git-scm.com) and [Node.js](https://nodejs.org/en/download/) (which comes with [npm](http://npmjs.com)) installed on your computer. From your command line:

```bash
# Clone this repository
git clone https://github.com/esportsinitiative/involvement-fair-signup
# Go into the repository
cd involvement-fair-signup
# Install dependencies and run the app
npm install && npm start
```

Built with Electron. Learn more about Electron and its API in the [documentation](http://electron.atom.io/docs/latest).

Also uses:

- [Bootstrap v3.3.7](https://getbootstrap.com/) for styling
- [JQuery v3.1.0](https://jquery.com/) for parsing

#### License [CC0 (Public Domain)](LICENSE.md)

# Examples

The running app:

![Running App](/Running App Example.PNG)

The generated file:

![Generated File](/Generated File Example.PNG)
