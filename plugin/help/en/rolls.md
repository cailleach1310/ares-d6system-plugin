---
toc: Game Systems
summary: Rolls (D6 System).
---
# Rolls
This game uses the D6 system. It is based on attributes, skills and specializations. You can roll skills or attributes, or roll a specified number of 6-sided dice.

In contrast to other systems that calculate successes per die, the D6 system sums up the pips of all dice rolled. The total is then compared to a diffculty level to determine the success level of the roll.

Please note: Effects of advantages, disadvantages and special abilities will have to be added manually as a modifier (dice or pips) if applicable.

Your character may gain fate points over time. You can choose to spend a fate point to double the total of a roll.

## Ability Rolls
`roll <ability>` - Rolls an attribute/skill/specialization.
`roll <skill>+<attribute>` - Rolls a skill or specialization with a specified attribute instead of the linked attribute.
`roll <ability>+<modifier>` - You can use a modifier for the roll. The modifier can be a number of dice (i.e. "2D") or a number.

## Spending a Fate Point
`roll/fate <ability with optional modifiers>` - You can spend a fate point to double the result of a roll.

## Rolling for Another Character
`roll <name>/<ability with optional modifiers>` - You can trigger a roll for another character. Fate won't work in this mode.

## NPC Rolls 
`roll <number of dice>+<modifier>` - For NPC rolls, you'll need to specify the total number of dice and pips for their roll, for example 'roll 2d+1'.

## Opposed Rolls
`roll <name>/<ability>+<modifier> vs <name>/<ability>+<modifier>` - Use this command for an opposed roll between PCs.
`roll <name>/<ability>+<modifier> vs <name of npc>/<dice>+<pips>` - You can also use this command for rolling against NPCs.

## Rolling Against a Difficulty
`roll <ability with optional modifiers>=<difficulty>` - Check an ability against a difficulty level.
`roll <name>/<ability with optional modifiers>=<difficulty>` - Check an ability level against a difficulty level for another PC.
