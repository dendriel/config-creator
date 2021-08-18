# Config Creator
Config Creator is a Web Application aimed to make it easy to create forms for inputting and exporting configuration
of any kind.

## Brief
The original idea of this project came from my constant need to create JSON configurations by hand for my game projects.
When I first created a solution to solve part of this problem, I came with [npc-data-manager](https://github.com/dendriel/npc-data-manager-rest)
that allowed to create fixed types of data.

In this scenario, when I needed to add a new type of data, although the code was generic, I still had to
copy/past some code and rebuild/repack everything. It was horrible.. =p

I know and I feel the project cold have just frontend and backend service. But I deliberately created and included other
services to have a microservices scenario I could use to deploy in AWS to study its services.

## Concepts

- Base types - are the input fields that the user interacts with. May be of different types:
    - text;
    - textArea;
    - number;
    - toggle;
    - list.
- Templates - group any number of base types to create a more meaningful type. Can group:
    - Base types;
    - Other templates.
- Project - is the workspace where it is possible instantiate templates in the form of Items and Collections (aka resources)
- Items - a unique data field in the project. Can be a base type or a template
- Collections - a list in the project that hold many Items of a base type (except for list) or template
- Configuration - the result of exporting the data contained in a project. After created, is available to download
in JSON format.


## Usage

To use Config Creator, first create a Project, then add resources to it. Templates can be created independently of projects
and can be added to project as resources. After the project is created, it will be automatically displayed in the Home page.

To start feeding data into the project, access the Home page and fill an Item or select a Collection and create a new Item
inside the collection.

To export the project data, access the configuration page and click in the 'Generate' button. It will create an export request
of the project in use. When the project data has been exported, the project entry in the listing from configuration page will
active the download button to retrieve the exported data.

Project related pages automatically loads data from the active project. So the project listing page allows to select
the active project for the current user.
