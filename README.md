# scratch-editor: The Scratch Editor Monorepo

If you'd like to use Scratch, please visit the [Scratch website](https://scratch.mit.edu/). You can build your own
Scratch project by pressing "Create" on that website or by visiting <https://scratch.mit.edu/projects/editor/>.

This is a source code repository for the packages that make up the Scratch editor and a few additional support
packages. Use this if you'd like to learn about how the Scratch editor works or to contribute to its development.

## การดัดแปลง / Modifications (AGPL-3.0 §5)

Repo นี้เป็นเวอร์ชัน**ดัดแปลง**ของ [scratchfoundation/scratch-editor](https://github.com/scratchfoundation/scratch-editor)
ต้นทาง licensed ภายใต้ AGPL-3.0-only — repo นี้คง license เดิมทุกประการ (`LICENSE`, `"license": "AGPL-3.0-only"`
ในทุก package)

สิ่งที่ดัดแปลง (รายละเอียดราย commit ดูได้ใน git history):

- แบรนด์ Sparky — สีธีม, โลโก้, ชื่อ tab, footer แทน Scratch purple/cat
- Firefly: mascot/sprite เริ่มต้น, costume ในคลัง, avatar
- Spark extension (`packages/scratch-vm/src/extensions/scratch3_spark/`) — บล็อกเซนเซอร์ฮาร์ดแวร์ Sparky
  (LED, IMU, mic, light, ToF, QR, ใบหน้า) ต่อ WebSocket ไป middleware ของผู้ใช้
- Docker image + helm chart (`kubernetes/`) สำหรับ deploy ขึ้น Kubernetes
- ตัวอย่างโปรเจกต์ `examples/`

AGPL-3.0 §13:  deployed service แสดงลิงก์ corresponding source ที่ footer
(<https://github.com/sparkyai-zi/scratch-editor> — repo นี้) rebuild จาก commit เดิมต้องได้ผลลัพธ์เดิม

เครื่องหมายการค้า Scratch (ชื่อ, โลโก้, Scratch Cat ฯลฯ) เป็นของ Scratch Foundation — ดู `TRADEMARK`

## What's in this repository?

The `packages` directory in this repository contains:

- `scratch-gui` provides the buttons, menus, and other elements that you interact with when creating and editing a
  project. It's also the "glue" that brings most of the other modules together at runtime.
- `scratch-media-lib-scripts` builds (or rebuilds) media libraries for the editor.
- `scratch-paint` provides a way to draw vector (SVG) or bitmap (PNG) images for costumes and backdrops.
- `scratch-render` draws backdrops, sprites, and clones on the stage.
- `scratch-storage` helps load project assets like images and sounds. It also provides `ScratchFetch`, a customized
  wrapper around `fetch`.
- `scratch-svg-renderer` processes SVG (vector) images for use with Scratch projects.
- `scratch-vm` is the virtual machine that runs Scratch projects.
- `task-herder` manages queues of tasks with throttling and concurrency limits.

_Please add to this list as more packages are migrated to the monorepo._

Each package has its own `README.md` file with more information about that package.

## Monorepo migration

### What's going on?

We're migrating the Scratch editor packages into this monorepo. This will allow us to manage all the packages that
make up the Scratch editor in one place, making  it easier to manage dependencies and make changes that affect
multiple packages.

### Why are there only a few packages in this repo?

We're migrating packages in stages. The current plan, which is subject to change, has us migrating repositories in
four batches. We plan to complete the migration within 2025.

### What will happen to the existing repositories?

The existing repositories will be archived and made read-only. Those repositories contain valuable work and
information, including but not limited to issues and pull requests. We plan to keep that information available for
reference, and to selectively migrate it to this new repository.

## Thank you

Scratch would not be what it is today without help from the global community of Scratchers and open-source
contributors. Thank you for your contributions and support. _[Scratch on!](https://scratch.mit.edu/projects/65347738/fullscreen/)_

## Donate

We provide [Scratch](https://scratch.mit.edu) free of charge, and want to keep it that way! Please consider making a
[donation](https://www.scratchfoundation.org/donate) to support our continued engineering, design, community, and
resource development efforts. Donations of any size are appreciated. Thank you!
