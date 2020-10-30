import template from './sw-plugin-card.html.twig';

const { Component } = Shopware;

Component.override('sw-plugin-card', {
    template
});
