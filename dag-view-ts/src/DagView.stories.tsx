import React from 'react';
import { Meta, StoryFn } from '@storybook/react';
import { DagViewComponent } from './DagView';
import { DagNode } from './dag-view';

export default {
    title: 'Components/DagView',
    component: DagViewComponent,
} as Meta;

const Template: StoryFn<{ nodes: DagNode[], frontiers: string[] }> = (args) => <DagViewComponent {...args} />;

export const Basic = Template.bind({});
Basic.args = {
    nodes: [
        { id: '1', deps: [], lamport: 1 },
        { id: '2', deps: ['1'], lamport: 2 },
        { id: '3', deps: ['1'], lamport: 3 },
        { id: '4', deps: ['2', '3'], lamport: 4 },
    ],
    frontiers: ['4'],
};

export const ComplexDag = Template.bind({});
ComplexDag.args = {
    nodes: [
        { id: 'A', deps: [], lamport: 1 },
        { id: 'B', deps: ['A'], lamport: 2 },
        { id: 'C', deps: ['A'], lamport: 3 },
        { id: 'D', deps: ['B'], lamport: 4 },
        { id: 'E', deps: ['B', 'C'], lamport: 5 },
        { id: 'F', deps: ['D', 'E'], lamport: 6 },
    ],
    frontiers: ['F'],
};

export const MultipleFrontiers = Template.bind({});
MultipleFrontiers.args = {
    nodes: [
        { id: 'X', deps: [], lamport: 1 },
        { id: 'Y', deps: ['X'], lamport: 2 },
        { id: 'Z', deps: ['X'], lamport: 3 },
    ],
    frontiers: ['Y', 'Z'],
};
