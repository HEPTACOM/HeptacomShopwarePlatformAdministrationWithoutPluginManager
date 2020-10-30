import template from './sw-plugin-file-upload.html.twig';

const { Component } = Shopware;

Component.override('sw-plugin-file-upload', {
    template
});
