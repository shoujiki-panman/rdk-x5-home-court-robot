# Home Court Robot — Stage 2 engineering plan

## Bill of materials

| Item | Qty | Model or source | Interface |
| --- | --- | --- | --- |
| RDK X5 and supply | 1 set | D-Robotics, RDK OS 3.5.0 | 5 V / 5 A USB-C PWR and LAN. [Board manual](https://d-robotics.github.io/rdk_x_doc/en/Quick_start/hardware_introduction/rdk_x5/) |
| Fixed USB camera and clamp | 1 each | Logitech C270 used in Stage 1 retest | USB 5 V from RDK. Frame only the evidence area. |
| StackChan and Strider | 1 each | M5Stack K151 / CoreS3, Yeq6X Strider | Local Wi-Fi, K151 battery while walking. [Strider design](https://github.com/Yeq6X/stackchan-strider/tree/852ae848d90ea7e85ada61842ec20ac88a86a82b) |
| Judge costume | 1 set | [Robe and gavel CAD](hardware/) | PLA and removable tape. Mounts on the fixed yoke. |
| Game audio | 1 set | Existing game speaker and mic | Keep the speaker near the judge for the pilot. |
| Scene props and lane | 1 set | Book, school scissors, tape, and a flat tray or lane | Unpowered. Keep the walking lane separate from hands and the tabletop edge. |

## Schedule

| Dates | Work and acceptance |
| --- | --- |
| Nov 27–Dec 1 | Print and fit the costume, test stock Strider drive and stop, and verify book and scissors detections on the RDK. |
| Dec 2–5 | Feed a confirmed label into the existing evidence record and verify that it reaches the verdict service. |
| Dec 6–9 | Connect the accepted verdict event to a bounded walk. Verify stop timing and replay behavior with the existing verdict audio. |
| Dec 10–15 | Test five sessions and the evidence and walking targets, then record one complete demo and publish measurements. |

## Risks and fallbacks

| Risk | Trigger | Response |
| --- | --- | --- |
| Wrong evidence label | Wrong or weak prediction in the marked area | Tune placement and thresholds. Ask the player to confirm or continue orally. |
| Robot drifts or loses Wi-Fi | Drift in the bench test, lost commands, or stop timeout | Use a short straight lane, local stop, and the firmware watchdog. Let the verdict continue with a stationary judge. |
| Costume rubs against the mechanism | Visual rubbing or degraded movement at low speed | Remove the costume and verify stock walking. Refit after changing the tape thickness or placement. |
| Duplicate requests restart movement | Repeated verdict events with the same case ID | Publish only after the existing guard. Deduplicate on the RDK, including reconnects. |
| Verdict/audio timing conflicts with motion | Verdict starts while the robot is still walking | Cancel motion at audio start and keep playback on the existing output path. |

## Repository structure

`src/home_court_robot/` holds the ROS 2 nodes and adapters, `src/home_court_msgs/` the interfaces, `launch/` startup, `models/` model provenance, `config/` camera and motion limits, `docs/` design and CAD, and `tests/` repeatable test scenarios.

[Roadmap](../../ROADMAP.md) · [Success targets](proposal.md#success-targets)
