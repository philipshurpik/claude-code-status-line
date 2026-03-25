/**
 * Tests for the StatusLine hook (status-line.js) - output formatting.
 */

const { describe, it } = require('node:test');
const assert = require('node:assert');
const { execFileSync } = require('node:child_process');
const path = require('node:path');

const HOOK = path.join(__dirname, '..', 'status-line.js');

function runHook(input) {
    return execFileSync('node', [HOOK], {
        input: JSON.stringify(input),
        encoding: 'utf8',
    });
}

function makeInput(overrides = {}) {
    return {
        session_id: 'test-sess',
        context_window: {
            used_percentage: 25,
            remaining_percentage: 75,
            context_window_size: 200000,
            total_input_tokens: 50000,
            total_output_tokens: 5000,
            current_usage: {
                cache_read_input_tokens: 40000,
                cache_creation_input_tokens: 10000,
            },
        },
        cost: { total_cost_usd: 0.123 },
        model: { id: 'claude-sonnet-4-6', display_name: 'Sonnet' },
        ...overrides,
    };
}

describe('status line output', () => {
    it('outputs colored bar with model name', () => {
        const output = runHook(makeInput());
        assert.ok(output.includes('Sonnet'), 'expected model name');
        assert.ok(output.includes('█'), 'expected filled bar segments');
        assert.ok(output.includes('░'), 'expected empty bar segments');
    });

    it('includes project and branch when cwd is a git repo', () => {
        const { execSync } = require('node:child_process');
        const input = makeInput({ cwd: process.cwd() });
        const output = runHook(input);
        const dirName = path.basename(process.cwd());
        assert.ok(output.includes(dirName), 'expected project name');
        // Branch symbol only appears when not on detached HEAD (CI uses detached checkout)
        let branch = '';
        try { branch = execSync('git branch --show-current', { encoding: 'utf8' }).trim(); } catch { /* ignore */ }
        if (branch) {
            assert.ok(output.includes('⎇'), 'expected branch symbol');
        }
    });

    it('omits project and branch when cwd is absent', () => {
        const output = runHook(makeInput());
        assert.ok(!output.includes('▪'), 'no project without cwd');
        assert.ok(!output.includes('⎇'), 'no branch without cwd');
    });

    it('outputs yellow bar at warning level (60K-80K tokens)', () => {
        const input = makeInput({
            context_window: { ...makeInput().context_window, used_percentage: 35, total_input_tokens: 70_000 },
        });
        const output = runHook(input);
        assert.ok(output.includes('\x1b[33m'), 'expected yellow ANSI code');
    });

    it('outputs orange bar at danger level (>=100K tokens)', () => {
        const input = makeInput({
            context_window: { ...makeInput().context_window, used_percentage: 55, total_input_tokens: 110_000 },
        });
        const output = runHook(input);
        assert.ok(output.includes('\x1b[38;5;208m'), 'expected orange ANSI code');
    });

    it('includes token counts', () => {
        const output = runHook(makeInput());
        assert.ok(output.includes('K/167K'), 'expected effective window size');
    });

    it('handles invalid JSON gracefully', () => {
        const output = execFileSync('node', [HOOK], {
            input: 'not json',
            encoding: 'utf8',
        });
        assert.strictEqual(output, 'Ctx: --');
    });

    it('displays rate_limits from live data', () => {
        const input = makeInput({
            rate_limits: {
                five_hour: { used_percentage: 42, resets_at: Math.floor(Date.now() / 1000) + 7200 },
                seven_day: { used_percentage: 15, resets_at: Math.floor(Date.now() / 1000) + 86400 },
            },
        });
        const output = runHook(input);
        assert.ok(output.includes('42%'), 'expected session usage');
        assert.ok(output.includes('15%'), 'expected weekly usage');
        assert.ok(output.includes('↻'), 'expected session reset icon');
        assert.ok(output.includes('⟳'), 'expected weekly reset icon');
    });

    it('displays reset time for rate_limits', () => {
        const input = makeInput({
            rate_limits: {
                five_hour: { used_percentage: 50, resets_at: Math.floor(Date.now() / 1000) + 3661 },
                seven_day: { used_percentage: 10, resets_at: Math.floor(Date.now() / 1000) + 90000 },
            },
        });
        const output = runHook(input);
        assert.ok(output.includes('1h1m') || output.includes('1h0m'), 'expected 5h reset time ~1h');
        assert.ok(output.includes('1d1h') || output.includes('1d0h'), 'expected 7d reset time ~1d');
    });
});
