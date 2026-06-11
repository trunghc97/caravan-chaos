const TRACK_SIZE = 16;
const FINISH_SPACE = TRACK_SIZE - 1;
const STARTING_COINS = 24;

const caravans = [
  {
    id: "saffron",
    name: "Saffron Guild",
    color: "#e4572e",
    accent: "#f2c14e",
    note: "gia vị",
  },
  {
    id: "glassback",
    name: "Glassback Cart",
    color: "#0f4c5c",
    accent: "#90e0ef",
    note: "kính muối",
  },
  {
    id: "manta",
    name: "Dune Manta",
    color: "#3d5a80",
    accent: "#f2c14e",
    note: "lụa gió",
  },
  {
    id: "brasswing",
    name: "Brasswing Wagon",
    color: "#2d936c",
    accent: "#f2c14e",
    note: "đồng hồ",
  },
  {
    id: "onyx",
    name: "Onyx Horn Cart",
    color: "#5f4b8b",
    accent: "#f7b267",
    note: "đá đêm",
  },
];

const routeLabels = {
  0: "Chợ",
  3: "Cổng",
  6: "Ốc đảo",
  9: "Hẻm",
  12: "Đền",
  15: "Đích",
};

const icons = {
  wind: `<svg class="svg-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M3 8h11a3 3 0 1 0-3-3"/><path d="M3 13h15a3 3 0 1 1-3 3"/><path d="M3 18h7"/></svg>`,
  event: `<svg class="svg-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3l2.3 5 5.4.7-4 3.8.9 5.4L12 15.3 7.4 18l.9-5.4-4-3.8 5.4-.7L12 3Z"/></svg>`,
  boost: `<svg class="svg-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 19V5"/><path d="m5 12 7-7 7 7"/></svg>`,
  snare: `<svg class="svg-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 5v14"/><path d="m19 12-7 7-7-7"/></svg>`,
  reset: `<svg class="svg-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M3 12a9 9 0 1 0 3-6.7"/><path d="M3 4v6h6"/></svg>`,
};

const tokenArt = {
  saffron: `
    <svg viewBox="0 0 48 48" aria-hidden="true">
      <path class="fill" d="M13 25h22l5 8H8l5-8Z"/>
      <path class="stroke" d="M11 33h28M15 25h18l5 8H10l5-8Z"/>
      <path class="stroke" d="M21 25V12l10 4-10 4"/>
      <circle class="accent" cx="16" cy="35" r="3"/>
      <circle class="accent" cx="32" cy="35" r="3"/>
    </svg>`,
  glassback: `
    <svg viewBox="0 0 48 48" aria-hidden="true">
      <path class="fill" d="M11 28c1-9 7-15 13-15s12 6 13 15l-5 8H16l-5-8Z"/>
      <path class="stroke" d="M11 28c1-9 7-15 13-15s12 6 13 15l-5 8H16l-5-8Z"/>
      <path class="stroke" d="M24 14v21M16 26h16"/>
      <path class="accent" d="M19 18h10l-5 7-5-7Z"/>
    </svg>`,
  manta: `
    <svg viewBox="0 0 48 48" aria-hidden="true">
      <path class="fill" d="M5 28c9-12 29-12 38 0-7 1-11 5-19 9-8-4-12-8-19-9Z"/>
      <path class="stroke" d="M5 28c9-12 29-12 38 0-7 1-11 5-19 9-8-4-12-8-19-9Z"/>
      <path class="stroke" d="M24 19v18M16 24l8 8 8-8"/>
      <circle class="accent" cx="24" cy="24" r="3"/>
    </svg>`,
  brasswing: `
    <svg viewBox="0 0 48 48" aria-hidden="true">
      <path class="fill" d="M13 31 8 18l12 5 4-10 4 10 12-5-5 13H13Z"/>
      <path class="stroke" d="M13 31 8 18l12 5 4-10 4 10 12-5-5 13H13Z"/>
      <path class="stroke" d="M14 35h20M19 31v4M29 31v4"/>
      <path class="accent" d="M21 24h6l-3 5-3-5Z"/>
    </svg>`,
  onyx: `
    <svg viewBox="0 0 48 48" aria-hidden="true">
      <path class="fill" d="M13 25h22l2 10H11l2-10Z"/>
      <path class="stroke" d="M13 25h22l2 10H11l2-10Z"/>
      <path class="stroke" d="M16 24c-3-5-2-9 3-12M32 24c3-5 2-9-3-12"/>
      <path class="stroke" d="M18 35h12"/>
      <circle class="accent" cx="17" cy="36" r="3"/>
      <circle class="accent" cx="32" cy="36" r="3"/>
    </svg>`,
};

const coords = [
  [4, 1],
  [4, 2],
  [4, 3],
  [4, 4],
  [3, 4],
  [3, 3],
  [3, 2],
  [3, 1],
  [2, 1],
  [2, 2],
  [2, 3],
  [2, 4],
  [1, 4],
  [1, 3],
  [1, 2],
  [1, 1],
];

const state = {
  activeTab: "action",
  bag: [],
  coins: STARTING_COINS,
  eventCard: null,
  lastWind: null,
  leg: 1,
  log: [],
  player: {
    finalContracts: [],
    legContracts: [],
  },
  raceOver: false,
  rivals: [],
  routeMarks: {},
  routeUsed: false,
  selectedSpace: 5,
  spaces: [],
};

const el = {
  coinValue: document.querySelector("#coinValue"),
  leaderName: document.querySelector("#leaderName"),
  panel: document.querySelector("#panelContent"),
  roundLabel: document.querySelector("#roundLabel"),
  track: document.querySelector("#track"),
  windCount: document.querySelector("#windCount"),
};

function initGame() {
  state.activeTab = "action";
  state.bag = caravans.map((caravan) => caravan.id);
  state.coins = STARTING_COINS;
  state.eventCard = null;
  state.lastWind = null;
  state.leg = 1;
  state.log = [];
  state.player = { finalContracts: [], legContracts: [] };
  state.raceOver = false;
  state.routeMarks = {};
  state.routeUsed = false;
  state.selectedSpace = 5;
  state.spaces = Array.from({ length: TRACK_SIZE }, () => []);
  state.spaces[0] = shuffle(caravans.map((caravan) => caravan.id));
  state.rivals = [
    { name: "Nira", coins: 22, legContracts: [], finalContracts: [] },
    { name: "Bahir", coins: 22, legContracts: [], finalContracts: [] },
    { name: "Tala", coins: 22, legContracts: [], finalContracts: [] },
  ];
  addLog("Chợ mở cổng. Các đoàn buôn xuất phát từ ô 0.");
  aiPrepareLeg();
  render();
}

function render() {
  const ranks = getStandings();
  const leader = getCaravan(ranks[0].id);
  el.coinValue.textContent = state.coins;
  el.roundLabel.textContent = state.raceOver ? "Kết thúc" : `Ngày ${state.leg}`;
  el.leaderName.textContent = leader.name;
  el.windCount.textContent = `${state.bag.length}/5`;
  renderTrack();
  renderTabs();
  if (state.activeTab === "action") renderActionPanel();
  if (state.activeTab === "contracts") renderContractsPanel();
  if (state.activeTab === "ledger") renderLedgerPanel();
}

function renderTrack() {
  el.track.innerHTML = Array.from({ length: TRACK_SIZE }, (_, index) => {
    const [row, col] = coords[index];
    const stack = state.spaces[index];
    const mark = state.routeMarks[index];
    const label = routeLabels[index] || `Ô ${index}`;
    const classes = [
      "space",
      index === 0 ? "is-start" : "",
      index === FINISH_SPACE ? "is-finish" : "",
      index === state.selectedSpace ? "is-selected" : "",
    ]
      .filter(Boolean)
      .join(" ");
    return `
      <button class="${classes}" type="button" data-space="${index}" style="grid-row:${row};grid-column:${col}">
        <span class="space-head">
          <span class="space-index">${index}</span>
          <span class="space-label">${label}</span>
          ${mark ? `<span class="route-mark ${mark.type}">${mark.type === "boost" ? "+1" : "-1"}</span>` : ""}
        </span>
        <span class="token-stack">
          ${stack.map((id) => renderToken(id)).join("")}
        </span>
      </button>
    `;
  }).join("");

  document.querySelectorAll("[data-space]").forEach((spaceButton) => {
    spaceButton.addEventListener("click", () => {
      state.selectedSpace = Number(spaceButton.dataset.space);
      render();
    });
  });
}

function renderTabs() {
  document.querySelectorAll(".tab-button").forEach((button) => {
    button.classList.toggle("is-active", button.dataset.tab === state.activeTab);
    button.onclick = () => {
      state.activeTab = button.dataset.tab;
      render();
    };
  });
}

function renderActionPanel() {
  const selectedLabel = routeLabels[state.selectedSpace] || `Ô ${state.selectedSpace}`;
  const eventMarkup = state.eventCard
    ? `<div class="event-card"><strong>${state.eventCard.title}</strong><p>${state.eventCard.text}</p></div>`
    : "";
  const lastMarkup = state.lastWind
    ? `<div class="last-card">
        ${renderToken(state.lastWind.id, true)}
        <div><strong>${getCaravan(state.lastWind.id).name}</strong><p>Gió đẩy ${state.lastWind.steps} ô${state.lastWind.markText ? `. ${state.lastWind.markText}` : ""}</p></div>
      </div>`
    : `<p class="empty-copy">Bàn thương lộ đang chờ phong ấn đầu tiên.</p>`;
  const endMarkup = state.raceOver
    ? `<div class="end-card"><strong>Phiên chợ khép lại</strong><p>${finalSummary()}</p></div>`
    : "";

  el.panel.innerHTML = `
    <div class="action-grid">
      ${endMarkup}
      <button class="primary-button" type="button" id="drawWind" ${state.raceOver ? "disabled" : ""}>
        ${icons.wind}
        Rút phong ấn gió
      </button>
      <div class="button-row">
        <button class="secondary-button" type="button" id="drawEvent" ${state.raceOver || state.coins < 2 ? "disabled" : ""}>
          ${icons.event}
          Sự kiện
        </button>
        <button class="secondary-button" type="button" id="restartGame">
          ${icons.reset}
          Chơi lại
        </button>
      </div>
      <div class="mini-stat-grid">
        <div class="mini-stat"><span>Ô chọn</span><strong>${selectedLabel}</strong></div>
        <div class="mini-stat"><span>Hợp đồng</span><strong>${state.player.legContracts.length}/2</strong></div>
        <div class="mini-stat"><span>Tuyến</span><strong>${state.routeUsed ? "Đã đặt" : "Trống"}</strong></div>
      </div>
      <div class="button-row">
        <button class="secondary-button" type="button" id="placeBoost" ${routeButtonDisabled() ? "disabled" : ""}>
          ${icons.boost}
          Ốc đảo
        </button>
        <button class="secondary-button warn" type="button" id="placeSnare" ${routeButtonDisabled() ? "disabled" : ""}>
          ${icons.snare}
          Ảo ảnh
        </button>
      </div>
      ${lastMarkup}
      ${eventMarkup}
    </div>
  `;

  document.querySelector("#drawWind").addEventListener("click", drawWind);
  document.querySelector("#drawEvent").addEventListener("click", drawEvent);
  document.querySelector("#restartGame").addEventListener("click", initGame);
  document.querySelector("#placeBoost").addEventListener("click", () => placeRouteMark("boost"));
  document.querySelector("#placeSnare").addEventListener("click", () => placeRouteMark("snare"));
}

function renderContractsPanel() {
  const ranks = getStandings();
  el.panel.innerHTML = `
    <div class="contract-list">
      ${ranks
        .map((rank, index) => {
          const caravan = getCaravan(rank.id);
          const legTaken = state.player.legContracts.filter((contract) => contract.caravanId === caravan.id).length;
          const finalTaken = state.player.finalContracts.some((contract) => contract.caravanId === caravan.id);
          return `
            <div class="caravan-row">
              ${renderToken(caravan.id, true)}
              <div class="caravan-meta">
                <strong>${index + 1}. ${caravan.name}</strong>
                <span>Ô ${rank.pos} · tầng ${rank.layer + 1} · ${caravan.note}</span>
              </div>
              <div class="contract-actions">
                <button class="icon-button" type="button" data-leg-contract="${caravan.id}" ${canSignLeg(caravan.id) ? "" : "disabled"}>Chặng</button>
                <button class="icon-button alt" type="button" data-final-contract="${caravan.id}" ${canSignFinal(caravan.id) ? "" : "disabled"}>Cuộc</button>
              </div>
            </div>
          `;
        })
        .join("")}
    </div>
  `;

  document.querySelectorAll("[data-leg-contract]").forEach((button) => {
    button.addEventListener("click", () => signLegContract(button.dataset.legContract));
  });
  document.querySelectorAll("[data-final-contract]").forEach((button) => {
    button.addEventListener("click", () => signFinalContract(button.dataset.finalContract));
  });
}

function renderLedgerPanel() {
  const scoreRows = [
    { name: "Bạn", coins: state.coins, detail: `${state.player.legContracts.length} chặng · ${state.player.finalContracts.length} cuộc` },
    ...state.rivals.map((rival) => ({
      name: rival.name,
      coins: rival.coins,
      detail: `${rival.legContracts.length} chặng · ${rival.finalContracts.length} cuộc`,
    })),
  ]
    .sort((a, b) => b.coins - a.coins)
    .map(
      (row, index) => `
      <div class="score-row">
        <div class="score-meta">
          <strong>${index + 1}. ${row.name}</strong>
          <span>${row.detail}</span>
        </div>
        <strong>${row.coins}</strong>
      </div>
    `,
    )
    .join("");

  const logRows = state.log.length
    ? state.log.map((line) => `<div class="log-entry">${line}</div>`).join("")
    : `<p class="empty-copy">Chưa có giao dịch.</p>`;

  el.panel.innerHTML = `
    <div class="action-grid">
      <div class="score-list">${scoreRows}</div>
      <div class="log-list">${logRows}</div>
    </div>
  `;
}

function renderToken(id, tiny = false) {
  const caravan = getCaravan(id);
  return `
    <span class="token ${tiny ? "tiny" : ""}" style="--token:${caravan.color};--accent:${caravan.accent}" title="${caravan.name}">
      ${tokenArt[id]}
    </span>
  `;
}

function routeButtonDisabled() {
  return (
    state.raceOver ||
    state.routeUsed ||
    state.coins < 1 ||
    state.selectedSpace <= 0 ||
    state.selectedSpace >= FINISH_SPACE ||
    Boolean(state.routeMarks[state.selectedSpace])
  );
}

function canSignLeg(caravanId) {
  return (
    !state.raceOver &&
    state.coins >= 2 &&
    state.player.legContracts.length < 2 &&
    state.player.legContracts.filter((contract) => contract.caravanId === caravanId).length < 1
  );
}

function canSignFinal(caravanId) {
  return (
    !state.raceOver &&
    state.coins >= 1 &&
    state.player.finalContracts.length < 3 &&
    !state.player.finalContracts.some((contract) => contract.caravanId === caravanId)
  );
}

function drawWind() {
  if (state.raceOver) return;
  if (state.bag.length === 0) {
    resolveLeg(false);
    return;
  }

  const caravanId = takeRandom(state.bag);
  const steps = rollSteps();
  const result = moveChain(caravanId, steps, "Gió");
  state.lastWind = {
    id: caravanId,
    steps,
    markText: result.markText,
  };
  addLog(`${getCaravan(caravanId).name} đi ${steps} ô${result.markText ? `, ${result.markText}` : ""}.`);

  if (isRaceFinished()) {
    resolveLeg(true);
  } else if (state.bag.length === 0) {
    resolveLeg(false);
  }
  render();
}

function drawEvent() {
  if (state.raceOver || state.coins < 2) return;
  state.coins -= 2;
  const events = [
    {
      title: "Gia vị vỡ thùng",
      text: "Đoàn cuối được đẩy thêm 2 ô.",
      apply() {
        const last = getStandings().at(-1);
        moveChain(last.id, 2, "Gia vị vỡ thùng");
        addLog(`${getCaravan(last.id).name} bám theo mùi gia vị, tiến 2 ô.`);
      },
    },
    {
      title: "Trạm ảo ảnh",
      text: "Đoàn dẫn đầu lùi 1 ô.",
      apply() {
        const first = getStandings()[0];
        moveChain(first.id, -1, "Trạm ảo ảnh");
        addLog(`${getCaravan(first.id).name} vòng qua trạm ảo ảnh, lùi 1 ô.`);
      },
    },
    {
      title: "Phiên chợ đêm",
      text: "Bạn nhận 4 dinar, đối thủ gần nhất nhận 2.",
      apply() {
        state.coins += 4;
        const rival = [...state.rivals].sort((a, b) => b.coins - a.coins)[0];
        rival.coins += 2;
        addLog(`Phiên chợ đêm sinh lời: bạn +4, ${rival.name} +2.`);
      },
    },
    {
      title: "Đường kính",
      text: "Một ô trước đoàn cuối trở thành ốc đảo.",
      apply() {
        const last = getStandings().at(-1);
        const target = Math.min(FINISH_SPACE - 1, last.pos + 1);
        if (target > 0 && !state.routeMarks[target]) {
          state.routeMarks[target] = { type: "boost", owner: "event" };
          addLog(`Đường kính mở ở ô ${target}.`);
        } else {
          state.coins += 2;
          addLog("Đường kính đã đông, bạn thu lại 2 dinar.");
        }
      },
    },
  ];

  const event = events[Math.floor(Math.random() * events.length)];
  state.eventCard = event;
  event.apply();

  if (isRaceFinished()) {
    resolveLeg(true);
  }
  render();
}

function placeRouteMark(type) {
  if (routeButtonDisabled()) return;
  state.coins -= 1;
  state.routeUsed = true;
  state.routeMarks[state.selectedSpace] = { type, owner: "player" };
  addLog(`${type === "boost" ? "Ốc đảo" : "Ảo ảnh"} được đặt ở ô ${state.selectedSpace}.`);
  render();
}

function signLegContract(caravanId) {
  if (!canSignLeg(caravanId)) return;
  state.coins -= 2;
  state.player.legContracts.push({ caravanId, leg: state.leg });
  addLog(`Bạn ký hợp đồng chặng cho ${getCaravan(caravanId).name}.`);
  render();
}

function signFinalContract(caravanId) {
  if (!canSignFinal(caravanId)) return;
  state.coins -= 1;
  state.player.finalContracts.push({ caravanId, leg: state.leg });
  addLog(`Bạn giữ hợp đồng chung cuộc cho ${getCaravan(caravanId).name}.`);
  render();
}

function moveChain(caravanId, delta, source) {
  const found = findCaravan(caravanId);
  if (!found) return { markText: "" };

  const moving = state.spaces[found.pos].splice(found.layer);
  let target = clamp(found.pos + delta, 0, FINISH_SPACE);
  let markText = "";

  if (delta > 0 && state.routeMarks[target]) {
    const mark = state.routeMarks[target];
    if (mark.type === "boost") {
      target = clamp(target + 1, 0, FINISH_SPACE);
      markText = "qua ốc đảo +1";
    } else {
      target = clamp(target - 1, 0, FINISH_SPACE);
      markText = "lạc vào ảo ảnh -1";
    }
  }

  state.spaces[target].push(...moving);
  return { markText, source };
}

function resolveLeg(isFinal) {
  const ranks = getStandings();
  const leader = ranks[0];
  const second = ranks[1];
  const third = ranks[2];

  const playerPayout = state.player.legContracts.reduce(
    (total, contract) => total + legPayout(contract.caravanId, leader, second),
    0,
  );
  if (playerPayout > 0) {
    state.coins += playerPayout;
    addLog(`Hợp đồng chặng trả ${playerPayout} dinar cho bạn.`);
  } else if (state.player.legContracts.length > 0) {
    addLog("Hợp đồng chặng của bạn không trúng.");
  }

  state.rivals.forEach((rival) => {
    const payout = rival.legContracts.reduce(
      (total, contract) => total + legPayout(contract.caravanId, leader, second),
      0,
    );
    rival.coins += payout;
  });

  if (isFinal) {
    resolveFinalContracts(leader, second, third);
    state.raceOver = true;
    state.activeTab = "ledger";
    addLog(`${getCaravan(leader.id).name} chạm cổng đích. Cuộc đua kết thúc.`);
    return;
  }

  state.leg += 1;
  state.bag = caravans.map((caravan) => caravan.id);
  state.eventCard = null;
  state.lastWind = null;
  state.player.legContracts = [];
  state.routeMarks = {};
  state.routeUsed = false;
  state.rivals.forEach((rival) => {
    rival.legContracts = [];
  });
  aiPrepareLeg();
  addLog(`Ngày ${state.leg} bắt đầu. Các hợp đồng chặng được mở lại.`);
}

function resolveFinalContracts(leader, second, third) {
  const playerPayout = state.player.finalContracts.reduce(
    (total, contract) => total + finalPayout(contract.caravanId, leader, second, third),
    0,
  );
  state.coins += playerPayout;
  addLog(`Hợp đồng chung cuộc trả ${playerPayout} dinar cho bạn.`);

  state.rivals.forEach((rival) => {
    const payout = rival.finalContracts.reduce(
      (total, contract) => total + finalPayout(contract.caravanId, leader, second, third),
      0,
    );
    rival.coins += payout;
  });
}

function aiPrepareLeg() {
  const ranks = getStandings();
  state.rivals.forEach((rival) => {
    if (rival.coins >= 2) {
      const target = weightedPick(ranks.slice(0, 4));
      rival.coins -= 2;
      rival.legContracts.push({ caravanId: target.id, leg: state.leg });
    }
    if (rival.finalContracts.length < 2 && rival.coins >= 1 && Math.random() > 0.42) {
      const target = weightedPick(ranks.slice(0, 5));
      if (!rival.finalContracts.some((contract) => contract.caravanId === target.id)) {
        rival.coins -= 1;
        rival.finalContracts.push({ caravanId: target.id, leg: state.leg });
      }
    }
  });
}

function getStandings() {
  const standings = [];
  state.spaces.forEach((stack, pos) => {
    stack.forEach((id, layer) => standings.push({ id, pos, layer }));
  });
  return standings.sort((a, b) => b.pos - a.pos || b.layer - a.layer);
}

function findCaravan(caravanId) {
  for (let pos = 0; pos < state.spaces.length; pos += 1) {
    const layer = state.spaces[pos].indexOf(caravanId);
    if (layer !== -1) return { pos, layer };
  }
  return null;
}

function getCaravan(id) {
  return caravans.find((caravan) => caravan.id === id);
}

function takeRandom(items) {
  const index = Math.floor(Math.random() * items.length);
  return items.splice(index, 1)[0];
}

function rollSteps() {
  return Math.floor(Math.random() * 3) + 1;
}

function legPayout(caravanId, leader, second) {
  if (caravanId === leader.id) return 8;
  if (caravanId === second.id) return 4;
  return 0;
}

function finalPayout(caravanId, leader, second, third) {
  if (caravanId === leader.id) return 14;
  if (caravanId === second.id) return 7;
  if (caravanId === third.id) return 3;
  return 0;
}

function isRaceFinished() {
  return state.spaces[FINISH_SPACE].length > 0;
}

function finalSummary() {
  const winner = [...state.rivals.map((rival) => ({ name: rival.name, coins: rival.coins })), { name: "Bạn", coins: state.coins }]
    .sort((a, b) => b.coins - a.coins)[0];
  return `${winner.name} thắng phiên chợ với ${winner.coins} dinar.`;
}

function addLog(message) {
  state.log.unshift(message);
  state.log = state.log.slice(0, 28);
}

function weightedPick(items) {
  const pool = [];
  items.forEach((item, index) => {
    const weight = Math.max(1, items.length - index);
    for (let i = 0; i < weight; i += 1) pool.push(item);
  });
  return pool[Math.floor(Math.random() * pool.length)];
}

function shuffle(items) {
  const copy = [...items];
  for (let i = copy.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}

initGame();
