fixture`Screenshot tests`
    .page`../index.html`;

test('Test', async t => {
    await t.expect(true).notOk();
});