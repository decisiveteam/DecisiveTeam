let chess = new Chess();
let currentDecision = null;
const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
const debugDisplay = document.getElementById('debug-display');
const joinButton = document.getElementById('join-game');
const commitButton = document.getElementById('commit');
const pollButton = document.getElementById('poll');
const board = document.getElementById('ascii-board');
const legalMoves = document.getElementById('legal-moves');

const poll = () => {
  fetch(`/games/chess/${match_id}/poll`, {
    method: 'GET',
    headers: {
      'X-CSRF-Token': csrfToken
    }
  })
  .then(response => response.json())
  .then(data => {
    if (data) {
      window.gameState = data;
      debugDisplay.textContent = JSON.stringify(data, null, 2);
    }
    // setTimeout(poll, 1000);
  });
}
const joinGame = () => {
  fetch(`/games/chess/${match_id}/join`, {
    method: 'POST',
    headers: {
      'X-CSRF-Token': csrfToken
    }
  })
  .then(response => response.json())
  .then(data => {
    if (data) {
      debugDisplay.textContent = JSON.stringify(data, null, 2);
    }
  });
}
const vote = (move, accepted, preferred) => {
  fetch(`/games/chess/${match_id}/vote`, {
    method: 'POST',
    headers: {
      'X-CSRF-Token': csrfToken,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      move: move,
      accepted: accepted,
      preferred: preferred
    })
  })
  .then(response => response.json())
  .then(data => {
    if (data) {
      debugDisplay.textContent = JSON.stringify(data, null, 2);
    }
  })
}
const commit = () => {
  fetch(`/games/chess/${match_id}/commit`, {
    method: 'POST',
    headers: {
      'X-CSRF-Token': csrfToken
    }
  })
  .then(response => response.json())
  .then(data => {
    if (data) {
      window.gameState = data;
      debugDisplay.textContent = JSON.stringify(data, null, 2);
      renderGame(data);
    }
  });
}

const asciiPositionToChessPositionMap = {
  rowNumbers: {
    1: 8,
    2: 7,
    3: 6,
    4: 5,
    5: 4,
    6: 3,
    7: 2,
    8: 1
  },
  columnNumbers: {
    5: 'a',
    8: 'b',
    11: 'c',
    14: 'd',
    17: 'e',
    20: 'f',
    23: 'g',
    26: 'h'
  }
};
const getChessPosition = (row, column) => {
  return `${asciiPositionToChessPositionMap.columnNumbers[column]}${asciiPositionToChessPositionMap.rowNumbers[row]}`;
};
const renderBoard = () => {
  board.innerHTML = '';
  const ascii = chess.ascii();
  ascii.split('\n').forEach((row, i) => {
    let div = document.createElement('div');
    if (i === 0 || i >= 9) {
      div.textContent = row;
    } else {
      div.innerHTML = row.split('').map((c, j) => {
        const position = getChessPosition(i, j);
        if (position) {
          return `<span data-ascii-position="${i},${j}" id="board-position-${position}">${c}</span>`;
        } else {
          return c;
        }
      }).join('');
    }
    board.appendChild(div);
  });
};
const renderLegalMoves = () => {
  let previousPiece = null;
  legalMoves.innerHTML = '';
  chess.moves({verbose:true}).forEach(move => {
    let li = document.createElement('li');
    if (previousPiece !== move.piece) {
      let pieceLi = document.createElement('li');
      pieceLi.innerHTML = `<h4>${move.piece}</h4>`;
      legalMoves.appendChild(pieceLi);
      previousPiece = move.piece;
    }
    li.textContent = `${move.from} -> ${move.to}`;
    li.style.cursor = 'pointer';
    li.addEventListener('mouseenter', () => {
      const boardStartEl = document.getElementById(`board-position-${move.from}`);
      const boardEndEl = document.getElementById(`board-position-${move.to}`);
      boardStartEl.style.backgroundColor = 'var(--color-fg-default)';
      boardStartEl.style.color = 'var(--color-canvas-default)';
      boardEndEl.style.backgroundColor = 'var(--color-fg-default)';
      boardEndEl.style.color = 'var(--color-canvas-default)';
    })
    li.addEventListener('mouseleave', () => {
      const boardStartEl = document.getElementById(`board-position-${move.from}`);
      const boardEndEl = document.getElementById(`board-position-${move.to}`);
      boardStartEl.style.backgroundColor = '';
      boardStartEl.style.color = '';
      boardEndEl.style.backgroundColor = '';
      boardEndEl.style.color = '';
    })
    li.addEventListener('click', () => {
      // chess.move({from: move.from, to: move.to});
      // renderBoard();
      // renderLegalMoves();
      if (li.style.color == 'yellow') {
        li.style.color = '';
        vote(move.san, false, false);
      } else {
        li.style.color = 'yellow';
        vote(move.san, true, false);
        // TODO: Implement preferred vote
      }
    })
    legalMoves.appendChild(li);
  });
}

const renderGame = (gameState) => {
  chess = new Chess();
  gameState.moves.forEach(move => {
    chess.move(move.result);
  });
  renderBoard();
  renderLegalMoves();
}

pollButton.addEventListener('click', poll);
joinButton.addEventListener('click', joinGame);
commitButton.addEventListener('click', commit);