# Home Court Robot — Stage 2 proposal

## Why

おうち裁判 (Home Court) is a game in which children and parents can hear each other's side of a small household disagreement, explain what their evidence shows, and hear a verdict. The robot brings the judge into the room and lets both players see which objects were observed in the evidence area.

## What we will build

The tabletop build follows the current two-player sequence: opening, each side's account, debate, evidence, closing remarks, verdict, and closing. It adds hardware to two moments in that sequence.

1. During evidence time, a player uses the existing evidence submission step and shows an object to a fixed USB camera. RDK X5 recognizes a visible object on its BPU, announces the observation through the game, and attaches the confirmed label to the existing evidence record. The player explains what it shows.
2. After the existing game accepts “判決お願いします” (“Please deliver the verdict”), the StackChan judge takes a short walk while the judges deliberate. The verdict and the existing gavel sound play at their usual points. The walk stops when its short window ends or the verdict audio begins.

For one demo, the child argues that the table is ready for reading and places a book down. The parent points out the scissors left there after craft time. RDK X5 records each submitted object. The players explain what each observation means, and the existing verdict engine considers the conversation and evidence.

Use one RDK X5, one fixed camera, and one K151 StackChan on the open-source four-legged Strider base. A 3D-printed robe and removable display gavel identify the judge. A small trial lane keeps the robot's movement clear of the evidence area. The pilot uses the existing game audio via a speaker near the judge, with onboard audio as a later integration target.

## Success targets

| Target | Method |
| --- | --- |
| Correctly label at least 18 of 20 submissions within 2 seconds. | Submit 10 books and 10 scissors. Measure from capture request to label result. Test five additional empty or obstructed scenes and verify that none creates a confirmed label. |
| In 9 of 10 integrated trials, issue one walk per verdict request, send stop by audio start or after 3 seconds, and confirm physical stop within 300 ms of the stop command. | Log verdict acceptance, drive and stop commands, audio start, and camera-observed motion. Test repeat requests, lost Wi-Fi, and a fast verdict separately. |
| Complete 4 of 5 parent–child sessions through closing in the existing stage order. | Observe one submitted object and at least one explanation of how it supports a player's claim. In a separate fault trial, verify that the verdict still plays with the robot disconnected. |

Stage 1 verified RDK X5 USB camera capture and YOLO11n inference. The costume CAD is available for a first print. Evidence recognition in the game and automated walking during deliberation are planned integration work. [Accepted Stage 1 evidence](https://github.com/D-Robotics/Robotics-Dream-Keeper-Challenge-Winter/pull/5)

[Architecture](architecture.md) · [Engineering plan](engineering-plan.md) · [Roadmap](../../ROADMAP.md)
