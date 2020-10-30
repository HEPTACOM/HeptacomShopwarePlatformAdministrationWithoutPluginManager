import './sw-plugin-list.scss';
import template from './sw-plugin-list.html.twig';

const { Component } = Shopware;

Component.override('sw-plugin-list', {
    template
});
