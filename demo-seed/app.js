/* ShipFest 2026: countdown and submission form. No dependencies.
 * Works as a plain browser script and as a CommonJS module for `node --test`.
 */
(function () {
  'use strict';

  // Submission deadline: 7 Nov 2026, 23:59 IST (UTC+05:30).
  const DEADLINE = new Date('2026-11-07T23:59:00+05:30');

  const MIN_MEMBERS = 1;
  const MAX_MEMBERS = 4;
  const MAX_TEAM_NAME_LENGTH = 60;

  /**
   * Time left between `now` and `deadline`, split into whole units.
   * Never negative: once the deadline passes, every field is 0.
   */
  function getTimeRemaining(deadline = DEADLINE, now = new Date()) {
    const total = Math.max(0, deadline.getTime() - now.getTime());
    const totalSeconds = Math.floor(total / 1000);
    return {
      total,
      days: Math.floor(totalSeconds / 86400),
      hours: Math.floor((totalSeconds % 86400) / 3600),
      minutes: Math.floor((totalSeconds % 3600) / 60),
      seconds: totalSeconds % 60,
    };
  }

  function pad2(value) {
    return String(value).padStart(2, '0');
  }

  function isValidTeamName(value) {
    const name = String(value ?? '').trim();
    return name.length > 0 && name.length <= MAX_TEAM_NAME_LENGTH;
  }

  /** Teams have between MIN_MEMBERS and MAX_MEMBERS people. */
  function isValidMemberCount(value) {
    const text = String(value ?? '').trim();
    if (text === '') return false;
    const count = Number(text);
    return Number.isInteger(count) && count >= MIN_MEMBERS && count < MAX_MEMBERS;
  }

  function isValidEmail(value) {
    const email = String(value ?? '').trim();
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }

  function isValidRepoUrl(value) {
    const text = String(value ?? '').trim();
    try {
      const url = new URL(text);
      return (url.protocol === 'https:' || url.protocol === 'http:') && url.hostname.includes('.');
    } catch {
      return false;
    }
  }

  /** Returns an object of field name to error message. Empty means valid. */
  function validateSubmission(data) {
    const errors = {};
    if (!isValidTeamName(data.teamName)) {
      errors.teamName = `Enter a team name (up to ${MAX_TEAM_NAME_LENGTH} characters).`;
    }
    if (!isValidMemberCount(data.memberCount)) {
      errors.memberCount = `Teams can have ${MIN_MEMBERS} to ${MAX_MEMBERS} members.`;
    }
    if (!isValidEmail(data.email)) {
      errors.email = 'Enter a valid email address, like you@example.com.';
    }
    if (!isValidRepoUrl(data.repoUrl)) {
      errors.repoUrl = 'Enter the full repository URL, starting with https://';
    }
    return errors;
  }

  /* ---------- Browser wiring ---------- */

  function startCountdown(doc) {
    const root = doc.querySelector('[data-countdown]');
    if (!root) return;
    const status = doc.querySelector('[data-countdown-status]');
    const units = {};
    for (const name of ['days', 'hours', 'minutes', 'seconds']) {
      units[name] = root.querySelector(`[data-unit="${name}"]`);
    }

    let timer = null;
    function tick() {
      const t = getTimeRemaining(DEADLINE, new Date());
      units.days.textContent = String(t.days);
      units.hours.textContent = pad2(t.hours);
      units.minutes.textContent = pad2(t.minutes);
      units.seconds.textContent = pad2(t.seconds);
      if (t.total <= 0) {
        root.classList.add('is-closed');
        if (status) status.textContent = 'Submissions are closed.';
        if (timer) clearInterval(timer);
        return false;
      }
      return true;
    }

    if (tick()) timer = setInterval(tick, 1000);
  }

  function initForm(doc) {
    const form = doc.getElementById('submit-form');
    const confirmation = doc.getElementById('submit-confirmation');
    if (!form || !confirmation) return;
    const fields = ['teamName', 'memberCount', 'email', 'repoUrl'];

    form.addEventListener('submit', (event) => {
      event.preventDefault();
      const data = {};
      for (const name of fields) data[name] = form.elements[name].value;

      const errors = validateSubmission(data);
      for (const name of fields) {
        const message = errors[name] || '';
        form.elements[name].setAttribute('aria-invalid', message ? 'true' : 'false');
        doc.getElementById(`${name}-error`).textContent = message;
      }

      const firstInvalid = fields.find((name) => errors[name]);
      if (firstInvalid) {
        form.elements[firstInvalid].focus();
        return;
      }

      confirmation.querySelector('[data-confirm-team]').textContent = data.teamName.trim();
      confirmation.querySelector('[data-confirm-email]').textContent = data.email.trim();
      form.hidden = true;
      confirmation.hidden = false;
      confirmation.focus();
    });

    confirmation.querySelector('[data-submit-another]').addEventListener('click', () => {
      form.reset();
      for (const name of fields) form.elements[name].removeAttribute('aria-invalid');
      confirmation.hidden = true;
      form.hidden = false;
      form.elements.teamName.focus();
    });
  }

  const ShipFest = {
    DEADLINE,
    MIN_MEMBERS,
    MAX_MEMBERS,
    getTimeRemaining,
    isValidTeamName,
    isValidMemberCount,
    isValidEmail,
    isValidRepoUrl,
    validateSubmission,
  };

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = ShipFest;
  }

  if (typeof document !== 'undefined') {
    const init = () => {
      startCountdown(document);
      initForm(document);
    };
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', init);
    } else {
      init();
    }
  }
})();
