# Ares D6System Plugin
An open d6 system plugin for AresMUSH. 

## Credits
Lyanna @ AresCentral

## Overview
This plugin can be used as an alternative to the fs3 system. It is based on the open D6 system and can be configured to fit various settings and requirements. The system offered here is based on the D6 Adventure sheet (https://ogc.rpglibrary.org/images/1/1b/D6_Adventure_v2.0_weg51011OGL.pdf).

You need to disable the fs3 plugin on the ares-webportal before you install this plugin.

### What this plugin covers
* Setting attributes, skills, specializations, advantages, disadvantages and special abilities in chargen, both on the game client and on the webportal.
* Rolling abilities from the game client and the webportal scene system.
* Enhancing rolls with spending fate and/or character points.
* Optional: Rolling against a difficulty level.
* In game sheet command and sheet integration on the character page of the webportal.
* Optional cron job for regularly awarding character points (similar to how it's done with xp on FS3 Systems).
* Staff game client commands to manage fate and character points (awarding/removing).
* A damage system based on wound levels, including an admin command for setting wound levels, player commands for healing other players and cron jobs for natural healing.

### This is a work in progress
This isn't complete yet, stuff is still subject to change. No warranty whatsoever. Certain features still have to be added, such as post chargen raising / adding abilities (which will have to be handled through requests / admin for now).

## Screenshots

### Game Client Roll Examples
![roll examples](/images/game_ability_roll_examples.PNG)

### Webportal Roll Ability Window
![webportal_roll](/images/webportal_ability_roll.PNG)

### Webportal Roll Result
![webportal_roll2](/images/webportal_ability_roll2.PNG)

### Webportal Chargen - Attributes
![roll examples](/images/webportal_chargen_attributes.PNG)

### Webportal Chargen - Skills
![roll examples](/images/webportal_chargen_skills.PNG)

### Webportal Chargen - Specializations
![roll examples](/images/webportal_chargen_specializations.PNG)

### Webportal Chargen - Add Option
![roll examples](/images/webportal_chargen_add_option.PNG)

### Webportal Chargen - Edit Option
![roll examples](/images/webportal_chargen_edit_option.PNG)

## Installation
In the game, run: plugin/install https://github.com/cailleach1310/ares-d6system-plugin

### Updating Custom Files
If you do not have any existing edits to these custom files, you can use the files in the custom_files folder of this repository as-is. If you do, then you may use them as templates to add the lines of code needed for the economy plugin.

#### aresmush/plugins/profile/custom_char_fields.rb
Update with: custom_files/custom_char_fields.rb

#### aresmush/plugins/chargen/custom_app_review.rb
Update with: custom_files/custom_app_review.rb

#### aresmush/plugins/scenes/custom_scene_data.rb
Update with: custom_files/custom_scene_data.rb

#### ares-webportal/app/templates/components/chargen-custom.hbs
Update with: custom_files/chargen-custom.hbs

#### ares-webportal/app/components/chargen-custom.js
Update with: custom_files/chargen-custom.hbs

#### ares-webportal/app/templates/components/chargen-custom-tabs.hbs
Update with: custom_files/chargen-custom-tabs.hbs

#### ares-webportal/app/custom-routes.js
Update with: custom_files/custom-routes.js

#### ares-webportal/app/templates/components/profile-custom.hbs
Update with: custom_files/profile-custom.hbs

#### ares-webportal/app/components/profile-custom.js
Update with: custom_files/profile-custom.js

#### ares-webportal/app/templates/components/profile-custom-tabs.hbs
Update with: custom_files/profile-custom-tabs.hbs

#### ares-webportal/app/templates/components/live-scene-custom-play.hbs
Update with: custom_files/live-scene-custom-play.hbs

#### ares-webportal/app/components/live-scene-custom-play.js
Update with: custom_files/live-scene-custom-play.js

## Adding Chargen Stages
Add the following lines to 'stages' in the chargen.yml, i.e. inbetween 'ranks' and 'background':

       reset:
         help: reset
       attributes:
         help: attributes
       skills:
         help: skills
       specializations:
         help: specializations
       advantages:
         help: advantages
       disadvantages:
         help: disadvantages
       specials:
         help: special abilities

## Adding Menu Items to the Webportal
#### /aresmush/game/config/website.yml
Add routes to the top bar menu under 'System' for the configured abilities and wound levels.

      top_navbar:
    (...)
    - title: System
      menu:
    (...)
        - title: Abilities List
          route: d6-abilities
        - title: Wound Levels
          route: d6-wound-levels
    (...)


## Configuration
After installation, you should check the d6system config files below and make adjustments where necessary. The keys in the configuration files are explained below.

### d6system_misc.yml 
#### achievements
There are two achievements defined, *d6_roll* for making a roll for the first time, and *d6_fate_spent* for spending a fate point on a roll. 

#### extranormal_blurb
Chargen info about extranormal attributes and skills.

#### sheet_columns
This is where you can customize the columns of the sheet, allowing you to arrange attribute-skill-blocks to optimize the look of the sheet. This affects both the in game sheet and the webportal sheet. Please note: Only those extranormal skills and attributes will be listed that have actually been learned. Also: "Extranormal" instead of attribute name will list the extranormal attributes and respective skills as one block.

#### show_sheet
Here you can toggle visibility of the sheet for other players.

#### cg_creation_points
Here you can set the max amount of creation points for character generation.

#### starting_char_points
By default 1.

#### starting_fate_points
By default 3.

#### cp_cron
Configuration for the cron job that handles the automatic character points raise of characters.

#### periodic_cp
Amount of character points that are gained with each run of the cron job.

#### max_char_hoard
Maximum character points that can be stored on a character.

#### max_fate_hoard
Maximum fate points that can be stored on a character.


### d6system_attrs.yml
#### attributes
Each attribute has a name and a desc. The attribute list can be adjusted here.

#### attributes_blurb
This is the respective info for chargen.

#### max_attr_cg_dice
Maximum number of dice you can distribute on attributes in chargen. Default is 18.

#### max_attr_dice
Maximum value of dice for attributes in chargen.

#### min_attr_dice
Minimum value of dice for attributes in chargen.

#### extranormal_attributes
Extranormal attributes are listed here, as some of the limitations are not valid for them. If you don't have any extranormal attributes on your game, set this to '{}'.

### d6system_skills.rb
#### max_skill_cg_dice
Maximum number of dice you can distribute on skills in chargen. Default is 7.

#### max_skill_dice
Maximum value of dice for skills in chargen.

#### min_skill_dice
Minimum value of dice for skills in chargen.

#### skills
Each skill has a name, a linked_attr and a desc. The skill list can be adjusted here.

#### skills_blurb
This is the respective skills info for chargen.

#### specializations_blurb
This is the respective info on skill specializations for chargen.

### d6system_advantages
#### advantages
Advantages have a name, a desc and ranks. Please note that ranks can be either a number or a slash-separated list of valid ranks.
This is where you would adjust the list of advantages for your game.

#### advantages_blurb
This is the chargen information on advantages.

### d6system_disadvantages
#### disadvantages
Disadvantages have a name, a desc and ranks. Please note that ranks can be either a number or a slash-separated list of valid ranks.
This is where you would adjust the list of disadvantages for your game.

#### disadvantages_blurb
This is the chargen information on disadvantages.

### d6system_specials
#### max_rank_specials
Maximum rank for special abilities in chargen.

#### special_abilities
Special abilities have a name, a desc and a cost. Cost defines the cost for the 1st rank of the ability. This is where you would add or remove special abilities for your game.

#### specials_blurb
This is the chargen information on special abilities.

#### specials_difficulty
This key should be set to 'cost' if you want each subsequent rank of a special ability to cost the same amount of creation points as the 1st rank. Set this to '1' or any other number, if you want a unified (cheaper) cost for ranks greater than 1.

### d6system_damage.yml
Specifics regarding wound levels and healing can be configured in this particular file.

#### assist_heal_block
Number of hours, during which a char will be blocked from healing another char after attempting a heal on them.

#### assist_healed_cron
Times, at which assisted heal blocks will be checked.

#### heal_skills
Skills that can be used by a healer for healing another char. Each skill can have a modifier configured (usually '0').

#### natural_heal_cron
Times for the natural heal cron check.

#### natural_heal_message
Text for the natural heal job that will be triggered by the natural_heal_cron.

#### wound_levels
Definition of the wound levels, including their name, effect, natural heal difficulty, assisted heal difficulty and resting time (in days).

#### wound_level_blurb
General information about wound levels for the wound level route.

#### wounds_fields
Definition of fields for the wound/list admin command.

## Uninstallation
Removing the plugin requires some code fiddling. See [Uninstalling Plugins](https://www.aresmush.com/tutorials/code/extras.html#uninstalling-plugins).

## License
Same as [AresMUSH](https://aresmush.com/license).
