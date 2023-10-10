---
toc: Game Systems
summary: Rolls (D6 System).
---
# Rolls
This game uses the D6 system. It is based on attributes, skills and specializations. You can roll skills or attributes, or roll a specified number of 6-sided dice.

In contrast to other systems that calculate successes per die, the D6 system sums up the pips of all dice rolled. The total is then compared to a diffculty level to determine the success level of the roll. A special feature of the D6 System is the *wild die*. One of the dice that are rolled is designated as the wild die (in our system it is the first die). A "6" on the wild die means a critical success, granting a reroll of the wild die. whereas a "1" is considered a critical failure. A critical failure means that the wild die and the highest of the other dice won't count towards the total.

Please note: Effects of advantages, disadvantages and special abilities will have to be added manually as a modifier (dice or pips) if applicable.

Your character may gain fate points over time. You can choose to spend a fate point to double the total of a roll. 

You can spend a character point on a roll to use one additonal die on it.

## Ability Rolls
`roll <ability>` - Rolls an attribute/skill/specialization.
`roll <skill>+<attribute>` - Rolls a skill or specialization with a specified attribute instead of the linked attribute.
`roll <ability>+<modifier>` - You can use a modifier for the roll. The modifier can be a number of dice (i.e. "2D") or a number.
`roll <number of dice>+<pips>` - You can roll a number of dice with a modifier. 

## Spending a Fate Point
`roll/fate <ability with optional modifiers>` - You can spend a fate point to double the result of a roll.

## Spending a Character Point
`roll/cp <ability with optional modifiers>` - You can spend a char point to add a +1D modifier to your roll.

## Spending both
`roll/all <ability with optional modifiers>` - You can spend both char point and fate point on a roll. 

## Rolling for Another Character
You can trigger a roll for another character. Fate or char points can't be used in this mode.
`roll <name>/<ability with optional modifiers>` - Roll ability.
`roll <name>/<number of dice with a modifier>` - Roll number of dice with modifier.

## NPC Rolls 
For NPC rolls, you'll need to specify the total number of dice and pips for their roll, for example 'roll 2d+1'.
`roll <NPC name>/<number of dice>+<modifier>` - Rolls a number of dice for an NPC.

## Opposed Rolls
`roll <name>/<ability>+<modifier> vs <name>/<ability>+<modifier>` - Use this command for an opposed roll between PCs.
`roll <name>/<ability>+<modifier> vs <name of npc>/<dice>+<pips>` - You can also use this command for rolling against NPCs.

## Rolling Against a Difficulty
`roll <ability with optional modifiers>=<difficulty>` - Check an ability against a difficulty level.
`roll <number of dice + modifier>=<difficulty>` - Check a number of dice with modifier against a difficulty level.
`roll/fate <ability with optional modifiers>=<difficulty>` - Check an ability against a difficulty level, spending a fate point.
`roll/cp  <ability with optional modifiers>=<difficulty>` - Check an ability against a difficulty level, spending a char point.
`roll/all  <ability with optional modifiers>=<difficulty>` - Check an ability against a difficulty level, spending a char and a fate point.

`roll <name>/<ability with optional modifiers>=<difficulty>` - Check an ability level against a difficulty level for another PC.
`roll <name>/<number of dice + modifier>=<difficulty>` - Check a number of dice with modifier against a difficulty level for another PC/NPC.
