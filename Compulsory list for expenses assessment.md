Compulsory list for expenses
================================

The static monthly expenses like rent, transportation, credit payments, family assistance, gym,
other regular payments will be subtracted from the salary.

There should be an option to input those expenses on a separate screen at the setup of the app:

Like:

    - Salary netto

    - List of regular expenses: here we need to opt for dynamic List of Cards containing TextInput widgets.
    The user should be able to give a name to each of regular expenses and type in the corresponding static amount

Dynamic (controllable) expenses should be also input at the start of the app.
Certain amount (optionally: certain percentage of the available amount (which remains after subtracting regular payments)) 
should be input for each dynamic expense category.

There should be a possibility to change the above settings via menu on the AppBar.

The chart on the main page sholud display spent amount and remaining amount for each category of dynamic expenses.

Total number of dynamic expense categories should not be more than seven.

Monitoring timespan: from 1st day of current month to the last day of that month.

Data should be collated into a database. Which database to use: a local NoSQL or SQL database, and a cloud database like Firebase.



