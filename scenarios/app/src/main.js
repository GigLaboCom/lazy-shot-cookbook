import './base.css';
import './overrides.css';

// A deliberately imperfect demo app. Every defect here is load-bearing: it is
// the "before" state of one of the cookbook's asset scenarios. See
// scenarios/README.md before fixing anything.

const routes = {
  '#/pricing': pricing,
  '#/checkout': checkout,
  '#/settings': settings,
};

function pricing() {
  return `
    <section class="card">
      <h2>Northwind Analytics Professional</h2>
      <p class="price"><span class="amount">€29</span><span class="period">/ month</span></p>
      <ul class="features">
        <li>Unlimited dashboards</li>
        <li>Ninety days of history</li>
        <li>Scheduled exports</li>
        <li>Priority support</li>
      </ul>
      <button class="cta">Start free trial</button>
    </section>
  `;
}

// SCENARIO A4 — the discount line renders as "-€NaN" because `discount` is a
// percentage string ("10%") that never gets parsed. Fix: parse it, then format.
function checkout() {
  const subtotal = 348.0;
  const discount = '10%';
  const reduction = subtotal * (Number.parseFloat(discount) / 100);
  const total = subtotal - reduction;

  return `
    <section class="card checkout">
      <h2>Order summary</h2>
      <dl class="lines">
        <dt>Professional, annual</dt><dd>€${subtotal.toFixed(2)}</dd>
        <dt>Launch discount</dt><dd class="discount">-€${reduction.toFixed(2)}</dd>
        <dt class="total-label">Total due today</dt><dd class="total">€${total.toFixed(2)}</dd>
      </dl>
      <button class="cta" id="pay">Pay €${total.toFixed(2)}</button>
    </section>
  `;
}

function settings() {
  return `
    <section class="card settings">
      <h2>Workspace settings</h2>
      <label class="row"><span>Workspace name</span><input value="Northwind" /></label>
      <label class="row"><span>Default currency</span>
        <select><option>EUR</option><option>USD</option></select>
      </label>
      <label class="row"><span>Weekly digest</span><input type="checkbox" checked /></label>
      <label class="row"><span>Retention</span>
        <select><option>90 days</option><option>1 year</option></select>
      </label>
      <button class="cta">Save changes</button>
    </section>
  `;
}

function render() {
  // The error dialog lives outside #app, so navigating away would otherwise
  // leave its backdrop dimming the next screen.
  document.querySelectorAll('.error-backdrop').forEach((el) => el.remove());

  const route = routes[location.hash] || pricing;
  document.getElementById('app').innerHTML = route();

  const pay = document.getElementById('pay');
  if (pay) pay.addEventListener('click', showError);
}

// SCENARIO A7 — a modal whose text cannot be selected, which is the whole
// reason OCR exists in recipe 05. Do not "fix" the user-select rule.
function showError() {
  const dialog = document.createElement('div');
  dialog.className = 'error-backdrop';
  dialog.innerHTML = `
    <div class="error-dialog" role="alertdialog">
      <h3>Payment could not be completed</h3>
      <p class="error-body">
        PaymentIntent pi_3QxT8mKz2Lp0Wn41 was rejected by the processor.<br />
        Reason: card_declined (insufficient_funds)<br />
        Request ID: req_8fJq2LmNv4Xc — retry after 30s
      </p>
      <button class="cta error-close">Dismiss</button>
    </div>
  `;
  dialog.querySelector('.error-close').addEventListener('click', () => dialog.remove());
  document.body.appendChild(dialog);
}

window.addEventListener('hashchange', render);
render();
